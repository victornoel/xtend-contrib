package fr.irit.smac.lib.contrib.xtend

import java.util.Map

class JavaExtensions {
		
	@Inline(value="assert $1 : $2", statementExpression=true)
	static def void doAssert(boolean b, String msg) {
		if (!b) {
			throw new RuntimeException(msg)
		}
	}
	
	@Pure
	@Inline(value="$3.format(\"%.\"+$2+\"f\", $1)", imported=String)
	static def toShortString(double d, int nbDigit) {
		String.format("%."+nbDigit+"f", d)
	}
	
	@Pure
	static def <K, V> Map<K, V> toMap(Iterable<Pair<K, V>> pairs) {
		val result = newLinkedHashMap()
		for (p : pairs) {
			result.put(p.key, p.value)
		}
		result
	}
	
	@Pure
	static def <K, V> V getOr(Map<K, V> m, K key, V or) {
		val r = m.get(key)
		if (r == null) or else r
	}
	
	@Pure
	@Inline(value="$1.get($2)")
	static def <K, V> V getSafe(Map<K, V> m, K key) {
		m.get(key)
	}
}