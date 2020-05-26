import de.hybris.platform.core.Registry;
import de.hybris.platform.core.model.user.UserModel;

authService = spring.getBean("defaultAuthenticationService");

class DefaultUserCredentials { 
    String userName;
    String password;

    DefaultUserCredentials(userName,password) { 
        this.userName=userName;
        this.password=password;
    }
} 

ArrayList userNameList = new ArrayList<DefaultUserCredentials>();
userNameList.add(new DefaultUserCredentials("admin","nimda"));
userNameList.add(new DefaultUserCredentials("anonymous","suomynona"));
userNameList.add(new DefaultUserCredentials("cmsmanager","1234"));
userNameList.add(new DefaultUserCredentials("csagent","1234"));
userNameList.add(new DefaultUserCredentials("productmanager","1234"));
userNameList.add(new DefaultUserCredentials("vjdbcReportsUser","1234"));
userNameList.add(new DefaultUserCredentials("hac_viewer","viewer"));
userNameList.add(new DefaultUserCredentials("hac_editor","editor"));

for (DefaultUserCredentials creds : userNameList) {
    print "Checking [" + creds.userName + "] - "
    
    try {
        UserModel user=authService.checkCredentials(creds.userName,creds.password);
        println "Using default password [" + creds.password + "] ⚠️"
    } catch(de.hybris.platform.servicelayer.security.auth.InvalidCredentialsException e) { 
        println "NOT using default password [" + creds.password + "] ✅"
    }
}