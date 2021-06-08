/*
 * Created By: Gangadhar G.
 * Created Date: May 21, 2021
 * Description: It Manages Authentication Activities like REST End Point URL, Token, Auth Type, etc from 'End_Point_Configuration__mdt'. 
*/
public class AthenticationUtility {
	
	//test comment for deployment
    public static Map<String, Object> getVssAuthDetails(){
        Map<String, Object> authMap = new Map<String, Object>();
        //test code for the deployment
        End_Point_Configuration__mdt endPointMetadata = [select Bearer_Token__c,URL__c from End_Point_Configuration__mdt where masterLabel='VSS Endpoint' LIMIT 1];
        if(endPointMetadata != null){
            authMap.put('token', endPointMetadata.Bearer_Token__c);
            authMap.put('endPoint', endPointMetadata.URL__c);
        }
        return authMap;
    }
    
    // This method gets RT Authentication details like Token, End Point URL.
    public static Map<String, Object> getRtAuthDetails(){
        Map<String, Object> authMap = new Map<String, Object>();
        End_Point_Configuration__mdt endPointMetadata = [select UserName__c, Password__c, URL__c from End_Point_Configuration__mdt where masterLabel='RT Endpoint' LIMIT 1];
        if(endPointMetadata != null){
            try{
                String jsonBody = '{"email":"' + endPointMetadata.UserName__c + '",';
                jsonBody += '"password":"' + endPointMetadata.Password__c + '"}';
                
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint(endPointMetadata.URL__c + 'api/v1/Auth');
                httpReq.setMethod('POST');
                httpReq.setHeader('Content-Type', 'application/json;charset=UTF-8');
                httpReq.setBody(jsonBody);
                httpReq.setTimeout(120000);
                Http httpObj = new Http();
                HttpResponse res = httpObj.send(httpReq);
                
                if(res.getStatusCode() == 200){
                    String resultSet = res.getBody();   
                    Map<String,Object> mapObj = (Map<String,Object>)Json.deserializeUntyped(resultSet);
                    String token = (String)mapObj.get('token');
                    System.debug('token:' + token);
                    authMap.put('token', token);
            		authMap.put('endPoint', endPointMetadata.URL__c);
                }
            }catch(Exception e){
                System.debug('Exception while calling Auth API:' + e.getMessage());
            }            
        }
        return authMap;
    }
}