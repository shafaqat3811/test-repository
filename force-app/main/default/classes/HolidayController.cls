public without sharing class HolidayController {
   
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getHolidays(String nationalId){
        
        List<Map<String, Object>> response = findHolidays(nationalId);
        updateSearchCount(nationalId);
        return response;
    }

    public static List<Map<String, Object>> findHolidays(String nationalId){
        Calendarific_Configuration__mdt configs = [Select API_Key__c, Base_Url__c from Calendarific_Configuration__mdt limit 1];
        
        String year = String.valueOf(getDate(nationalId)).split('-')[0];
        HttpRequest request = new HttpRequest();
        request.setEndpoint(configs.Base_Url__c+'/holidays?api_key='+configs.API_Key__c+'&country=ZA&year='+year);
        request.setMethod('GET');
        Http http = new Http();
        HTTPResponse response = http.send(request);

        List<Map<String, Object>> availableHolidays = new List<Map<String, Object>>();

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> responseMap = (Map<String, Object>) result.get('response');
            List<Object> holidays = (List<Object>) responseMap.get('holidays');

            for (Object availableHoliday : holidays) {
                Map<String, Object> holiday = (Map<String, Object>) availableHoliday;
                if(holiday.get('primary_type') == 'Public Holiday'){
                    Map<String, Object> d = (Map<String, Object>) holiday.get('date');
                    Map<String, Object> dt = (Map<String, Object>) d.get('datetime');
                    Map<String, Object> h = new Map<String, Object>();
                    h.put('name', holiday.get('name'));
                    h.put('year', dt.get('year'));
                    h.put('description', holiday.get('description'));
                    h.put('month', dt.get('month'));
                    h.put('day', dt.get('day'));
                    h.put('date', d.get('iso'));
                    h.put('primary_type', holiday.get('primary_type'));
                    h.put('type', holiday.get('type'));
                    availableHolidays.add(h);
                }
            }
        }
        return availableHolidays;
    }

    public static void updateSearchCount(String nationalId){
        list<Search_History__c> searchList=[select id, Search_Count__c from Search_History__c where Name=:nationalId];
        
        Search_History__c newSearch = new Search_History__c();
        newSearch.Name  = nationalId;
        newSearch.Date_of_Birth__c  = getDate(nationalId);
        newSearch.Gender__c  = getGender(nationalId);
        newSearch.Citizenship__c  = getCitizenship(nationalId);
        if(searchList.size()>0){
            newSearch.Search_Count__c = searchList.get(0).Search_Count__c+1;
        }else{
            newSearch.Search_Count__c = 1;
        }
        upsert newSearch Name;
    }

    public static Date getDate(String nationalId){
        String year = nationalId.substring(0, 2);
        String month = nationalId.substring(2, 4);
        String day = nationalId.substring(4, 6);

        if (Integer.valueOf(year)<=23) {
            year = '20'+year;
        }else {
            year = '19'+year;
        }
        return Date.parse(month+'/'+day+'/'+year);
    }

    public static String getGender(String nationalId){
        if(Integer.valueOf(Integer.valueOf(nationalId.substring(6, 10)))<=4999){
            return 'Female';
        }else {
            return 'Male';
        }
    }

    public static Boolean getCitizenship(String nationalId){
        if (Integer.valueOf(nationalId.substring(10,11))==0) {
            return true;
        }else {
            return false;
        }
    }
}