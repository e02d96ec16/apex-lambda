public class ReduceTransform implements SObjectToSObjectFunction {
	private SObject prototype;
	private Map<String, Object> prototypePopulatedFieldsMap;
	private Map<String, Schema.SObjectField> fieldsTokens;
	private Map<String, Schema.DisplayType> fieldsTypes;
	private final Set<Schema.DisplayType> summableFieldTypes = new Set<Schema.DisplayType>{
		Schema.DisplayType.String
	};
	private final Map<Schema.DisplayType, String> fieldTypeToApexType = new Map<Schema.DisplayType, String>{
		Schema.DisplayType.String => 'String'
	};

	public SObject apply(SObject record) {
		Map<String, Object> recordPopulatedFieldsMap = record.getPopulatedFieldsAsMap();

		for (String field : recordPopulatedFieldsMap.keySet()) {
			Boolean isFieldPresent = prototypePopulatedFieldsMap.containsKey(field);
			Object fieldValue = record.get(field);
			if(isFieldSummable(field)){
				prototype.put(field, sumUp(prototype.get(field), fieldValue, fieldsTypes.get(field)));
			}
			else if(!isFieldPresent){
				prototype.put(field, fieldValue);
			}
		}
		return prototype;
	}

	public ReduceTransform(sObject prototype) {
		this.prototype = prototype;
		this.prototypePopulatedFieldsMap = prototype.getPopulatedFieldsAsMap();
		this.fieldsTokens = prototype.getSObjectType().getDescribe().fields.getMap();
		this.fieldsTypes = new Map<String, Schema.DisplayType>();
	}

	private Boolean isFieldSummable(String field){
		if(!fieldsTypes.containsKey(field)){
			fieldsTypes.put(field, fieldsTokens.get(field).getDescribe().getType());
		}
		return summableFieldTypes.contains(fieldsTypes.get(field));
	}

	private Object sumUp(Object val1, Object val2, Schema.DisplayType fieldType){
		Object sum;
		switch on fieldTypeToApexType.get(fieldType) {
			when 'String' {
				sum = String.valueOf(val1) + String.valueOf(val2);
			}
		}
		return sum;
	}
}