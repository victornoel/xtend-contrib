package fr.irit.smac.lib.contrib.xtend.macros

import de.oehme.xtend.contrib.Cached
import de.oehme.xtend.contrib.CachedProcessor
import de.oehme.xtend.contrib.SignatureHelper
import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractMethodProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration

@Retention(RetentionPolicy.SOURCE)
@Target(ElementType.METHOD)
@Active(StepProcessor)
annotation StepCached {
	boolean resetBefore = true
	boolean resetAfter = false
}

class StepProcessor extends AbstractMethodProcessor {
	
	override doTransform(MutableMethodDeclaration annotatedMethod, extension TransformationContext context) {
		val extension transformations = new SignatureHelper(context)
		
		if (annotatedMethod.returnType.inferred) {
			addError(annotatedMethod, "The method must explicitly declare a return type (void accepted) for @StepCached to work.")
			return
		}
		
		val clazz = annotatedMethod.declaringType
		val cached = clazz.declaredMethods.filter[
			findAnnotation(Cached.findTypeGlobally) != null
		]
		
		if (cached.empty) {
			return
		}
		
		val name = annotatedMethod.simpleName
		
		val annot = annotatedMethod.findAnnotation(StepCached.findTypeGlobally)
		
		val resetBefore = annot.getBooleanValue("resetBefore")
		val resetAfter = annot.getBooleanValue("resetAfter")
		
		annotatedMethod.addIndirection("_reset_"+name, '''
			«IF resetBefore»
			«FOR c: cached»
			«c.invalidate»
			«ENDFOR»
			«ENDIF»
			«IF !annotatedMethod.returnType.void»«annotatedMethod.returnType» res = «ENDIF»_reset_«name»(«annotatedMethod.parameters.join(",")[simpleName]»);
			«IF resetAfter»
			«FOR c: cached»
			«c.invalidate»
			«ENDFOR»
			«ENDIF»
			«IF (!annotatedMethod.returnType.void)»return res;«ENDIF»
		''')
	}
	
	def String invalidate(MethodDeclaration c) {
		switch (c.parameters.size) {
			case 0: '''«CachedProcessor.cacheFieldName(c)» = null;'''
			default: '''«CachedProcessor.cacheFieldName(c)».invalidateAll();'''
		}
	}
	
}