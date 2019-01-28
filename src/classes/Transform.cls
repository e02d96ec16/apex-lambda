public with sharing class Transform {
	public static RecordTransform record(SObject record) {
		return new RecordTransform(record);
	}
	public static ReduceTransform sum(SObject record) {
		return new ReduceTransform(record);
	}
}