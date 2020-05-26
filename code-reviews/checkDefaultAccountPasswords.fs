SELECT {uid},{name},{encodedpassword},{passwordencoding},{loginDisabled}
  FROM {user}
 WHERE
   lower({uid}) like '%admin%' or
   lower({uid}) like '%manager%' or
   lower({uid}) like '%agent%' or
   lower({uid}) like '%user%' or
   lower({uid}) like '%backoffice%' or
   lower({uid}) like '%hac%' or
   lower({uid}) like '%hcs%' or
   lower({uid}) like 'wfl%'