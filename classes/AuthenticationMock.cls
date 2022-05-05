@isTest
global class AuthenticationMock implements HttpCalloutMock {
  /**
   * @author Cloud Analogy
   * @date 02/08/2021
   * @description ......
   * @param req ......
   * @return HTTPResponse res ......
   */
  global HTTPResponse respond(HTTPRequest req) {
    String endpoint = req.getEndpoint();
    String body = req.getBody();
    if (body.contains('&grant_type=client_credentials')) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0dHdQd1QzVVp3NGhCU3hnUk5naVg1TTZzdW45eEFkSkdCNk5CVHJNbWZzIn0.eyJleHAiOjE2MjU0NzAzNjgsImlhdCI6MTYyNTQ2Njc2OCwianRpIjoiM2Y1ZDliOGYtMWVhZS00MzgzLTlhMDktYTY5YzZiYjJiMDJhIiwiaXNzIjoiaHR0cHM6Ly9zc28uc3lzdGVsb3Nwcm8uY29tL2F1dGgvcmVhbG1zL2FwcCIsImF1ZCI6WyJzYWxlc2ZvcmNlIiwicmVhbG0tbWFuYWdlbWVudCIsImFjY291bnQiXSwic3ViIjoiNjI0MGQzMmYtYTY1Mi00NzJjLTg1YmYtNDJjYjI3ZGQyNDIwIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoic2FsZXNmb3JjZSIsInNlc3Npb25fc3RhdGUiOiJkZTI4NjdmYy0wNTg2LTQyNTUtOTM1My02YmJjYTExMzU3MjYiLCJhY3IiOiIxIiwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbImFkbWluaXN0cmF0b3IiLCJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsicmVhbG0tbWFuYWdlbWVudCI6eyJyb2xlcyI6WyJ2aWV3LXJlYWxtIiwidmlldy1pZGVudGl0eS1wcm92aWRlcnMiLCJtYW5hZ2UtaWRlbnRpdHktcHJvdmlkZXJzIiwiaW1wZXJzb25hdGlvbiIsInJlYWxtLWFkbWluIiwiY3JlYXRlLWNsaWVudCIsIm1hbmFnZS11c2VycyIsInF1ZXJ5LXJlYWxtcyIsInZpZXctYXV0aG9yaXphdGlvbiIsInF1ZXJ5LWNsaWVudHMiLCJxdWVyeS11c2VycyIsIm1hbmFnZS1ldmVudHMiLCJtYW5hZ2UtcmVhbG0iLCJ2aWV3LWV2ZW50cyIsInZpZXctdXNlcnMiLCJ2aWV3LWNsaWVudHMiLCJtYW5hZ2UtYXV0aG9yaXphdGlvbiIsIm1hbmFnZS1jbGllbnRzIiwicXVlcnktZ3JvdXBzIl19LCJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6Im9wZW5pZCBjdXN0b20gcHJvZmlsZSBzYWxlc2ZvcmNlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJTd2FwbmlsIFNlbiIsImdyb3VwcyI6WyIvc2FsZXNmb3JjZS9hZG1pbmlzdHJhdG9yIl0sInByZWZlcnJlZF91c2VybmFtZSI6InN3YXBuaWwuc2VuQGNsb3VkYW5hbG9neS5jb20iLCJsb2NhbGUiOiJlbiIsImdpdmVuX25hbWUiOiJTd2FwbmlsIiwiZmFtaWx5X25hbWUiOiJTZW4iLCJlbWFpbCI6InN3YXBuaWwuc2VuQGNsb3VkYW5hbG9neS5jb20ifQ.VeZdwI30BsXdYydRDbJVVUJjPFBh2E_fK99d85ynQoBhXcwnh-_7uCdSGgH0c9r6DIsWnCC1DdkmJ7K3cA6hL5_c9e7YRDD3HHgNEPLu7l-umXKULeC8pbnQH7AILwKgjhl1XXXMdsqIIi5pUWZV1pacuFrEnO4MHNj9yuP2jMC7z4vcslxYptORQ-LbevMl9wlbB7qGZgIjSPLisMuB-eigyYqgzADaEK2mys_KBKsdMiAIoaHAUv2NO6wsHgCD99JetTwM2nff2KSORHRV4-5UKMfRb9g4c_ZSb8EL844DXWvFvmdPqFOWJAZPov34DL9yZ-uG3bwknFont7cCpw","expires_in":3600,"refresh_expires_in":36000,"refresh_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIyMDQ5MzVlNi0zZDk0LTQ5ZDktODEzNy1kMjZhNjFlMGQyNjMifQ.eyJleHAiOjE2MjU1MDI3NjgsImlhdCI6MTYyNTQ2Njc2OCwianRpIjoiODJiNjA4ODMtYTE5My00N2FjLWFhYjQtMDRhNzFkZjZkNTgzIiwiaXNzIjoiaHR0cHM6Ly9zc28uc3lzdGVsb3Nwcm8uY29tL2F1dGgvcmVhbG1zL2FwcCIsImF1ZCI6Imh0dHBzOi8vc3NvLnN5c3RlbG9zcHJvLmNvbS9hdXRoL3JlYWxtcy9hcHAiLCJzdWIiOiI2MjQwZDMyZi1hNjUyLTQ3MmMtODViZi00MmNiMjdkZDI0MjAiLCJ0eXAiOiJSZWZyZXNoIiwiYXpwIjoic2FsZXNmb3JjZSIsInNlc3Npb25fc3RhdGUiOiJkZTI4NjdmYy0wNTg2LTQyNTUtOTM1My02YmJjYTExMzU3MjYiLCJzY29wZSI6Im9wZW5pZCBjdXN0b20gcHJvZmlsZSBzYWxlc2ZvcmNlIGVtYWlsIn0.Jt32vrlaNOR5ZRTFCrtlAyzklZen4lMdRvfpA1A2aiI","token_type":"bearer","id_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0dHdQd1QzVVp3NGhCU3hnUk5naVg1TTZzdW45eEFkSkdCNk5CVHJNbWZzIn0.eyJleHAiOjE2MjU0NzAzNjgsImlhdCI6MTYyNTQ2Njc2OCwiYXV0aF90aW1lIjowLCJqdGkiOiJmZDFmZjc5ZC0wYTAwLTRjMjUtOTNkNS04YmNiMTFiMDM0NzgiLCJpc3MiOiJodHRwczovL3Nzby5zeXN0ZWxvc3Byby5jb20vYXV0aC9yZWFsbXMvYXBwIiwiYXVkIjoic2FsZXNmb3JjZSIsInN1YiI6IjYyNDBkMzJmLWE2NTItNDcyYy04NWJmLTQyY2IyN2RkMjQyMCIsInR5cCI6IklEIiwiYXpwIjoic2FsZXNmb3JjZSIsInNlc3Npb25fc3RhdGUiOiJkZTI4NjdmYy0wNTg2LTQyNTUtOTM1My02YmJjYTExMzU3MjYiLCJhdF9oYXNoIjoiUWdHeDcxQl9FdUgtaWdjXzJxbUV5USIsImFjciI6IjEiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IlN3YXBuaWwgU2VuIiwiZ3JvdXBzIjpbIi9zYWxlc2ZvcmNlL2FkbWluaXN0cmF0b3IiXSwicHJlZmVycmVkX3VzZXJuYW1lIjoic3dhcG5pbC5zZW5AY2xvdWRhbmFsb2d5LmNvbSIsImxvY2FsZSI6ImVuIiwiZ2l2ZW5fbmFtZSI6IlN3YXBuaWwiLCJmYW1pbHlfbmFtZSI6IlNlbiIsImVtYWlsIjoic3dhcG5pbC5zZW5AY2xvdWRhbmFsb2d5LmNvbSJ9.eqCAt-EuG1LKMzB5a_11JV_oJBgl7a1anq0lPVLNz3dCv2AKBNVgKkY6LQdd5bhPbxxBgEb8MuNtn2iRRpZ600ivCrOXr2GEGq9hrPw7CFP4rL-w35wo-WES4JhgUnJJlIA1BzJnMp0uFKiyLCBTjfe4OJRDeDR_wUM0jEfdI_QBCjGx3qaX85BWn8xZm1aaM0WRmBLLFaUNOsr0dbPIoKl4jEH0tgWq-2-1z_QwUdBvzqCclg3AlQJwB-s0unjmXTtCNotv9WnbIKO0jft7L6CS5IRwUdJ2yU4dIk2e-JPyJ0MP7tCne8BqkNSV5L7zAnVvKXf6uUzCpUM-HP7q-g","not-before-policy":1610473598,"session_state":"de2867fc-0586-4255-9353-6bbca1135726","scope":"openid custom profile salesforce email"}'
      );
      res.setStatusCode(200);
      return res;
    } else if (body.contains('&grant_type=refresh_token')) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0dHdQd1QzVVp3NGhCU3hnUk5naVg1TTZzdW45eEFkSkdCNk5CVHJNbWZzIn0.eyJleHAiOjE2MjU0NzA0NjEsImlhdCI6MTYyNTQ2Njg2MSwianRpIjoiNzFlNzUwNGMtOTgxOS00NGVlLWJlN2QtOGU4ZDA4ZThkNjJlIiwiaXNzIjoiaHR0cHM6Ly9zc28uc3lzdGVsb3Nwcm8uY29tL2F1dGgvcmVhbG1zL2FwcCIsImF1ZCI6WyJzYWxlc2ZvcmNlIiwicmVhbG0tbWFuYWdlbWVudCIsImFjY291bnQiXSwic3ViIjoiNjI0MGQzMmYtYTY1Mi00NzJjLTg1YmYtNDJjYjI3ZGQyNDIwIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoic2FsZXNmb3JjZSIsInNlc3Npb25fc3RhdGUiOiJkZTI4NjdmYy0wNTg2LTQyNTUtOTM1My02YmJjYTExMzU3MjYiLCJhY3IiOiIxIiwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbImFkbWluaXN0cmF0b3IiLCJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsicmVhbG0tbWFuYWdlbWVudCI6eyJyb2xlcyI6WyJ2aWV3LXJlYWxtIiwidmlldy1pZGVudGl0eS1wcm92aWRlcnMiLCJtYW5hZ2UtaWRlbnRpdHktcHJvdmlkZXJzIiwiaW1wZXJzb25hdGlvbiIsInJlYWxtLWFkbWluIiwiY3JlYXRlLWNsaWVudCIsIm1hbmFnZS11c2VycyIsInF1ZXJ5LXJlYWxtcyIsInZpZXctYXV0aG9yaXphdGlvbiIsInF1ZXJ5LWNsaWVudHMiLCJxdWVyeS11c2VycyIsIm1hbmFnZS1ldmVudHMiLCJtYW5hZ2UtcmVhbG0iLCJ2aWV3LWV2ZW50cyIsInZpZXctdXNlcnMiLCJ2aWV3LWNsaWVudHMiLCJtYW5hZ2UtYXV0aG9yaXphdGlvbiIsIm1hbmFnZS1jbGllbnRzIiwicXVlcnktZ3JvdXBzIl19LCJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6Im9wZW5pZCBjdXN0b20gcHJvZmlsZSBzYWxlc2ZvcmNlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJTd2FwbmlsIFNlbiIsImdyb3VwcyI6WyIvc2FsZXNmb3JjZS9hZG1pbmlzdHJhdG9yIl0sInByZWZlcnJlZF91c2VybmFtZSI6InN3YXBuaWwuc2VuQGNsb3VkYW5hbG9neS5jb20iLCJsb2NhbGUiOiJlbiIsImdpdmVuX25hbWUiOiJTd2FwbmlsIiwiZmFtaWx5X25hbWUiOiJTZW4iLCJlbWFpbCI6InN3YXBuaWwuc2VuQGNsb3VkYW5hbG9neS5jb20ifQ.YK2ICHOFk6bK4DBi1_VfsHvE0b_4Wv-xCkm7NsuiFOYzFgQq4nU7MLzvqHtwc-z0Rn2-a-MdVbmhVwX17XWYHQFVFXIy8K8rk_9HzEgbLz1XYTGIbBXx-ikequWWArKBC5ar2JBWegL_IuuPvTKVcOaHEuoTT8yFkLUGct7pCQmx5EmKLXrmlSG_Fnkg8iUjAsJBCCDpfLJe9PytM8O6yF2TMQOmtq2CHCcf__beKNn3hE8Fv9KC8-LXz-x6BxrAN3FcQ2yhBSJvFLeePryjSUB6_8FUo43kIxTWIucM773QScM8JxVMIQmWyljoe8gXBWlTn1QFTKBu4L1ZcR3gxA","expires_in":3600,"refresh_expires_in":35907,"refresh_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIyMDQ5MzVlNi0zZDk0LTQ5ZDktODEzNy1kMjZhNjFlMGQyNjMifQ.eyJleHAiOjE2MjU1MDI3NjgsImlhdCI6MTYyNTQ2Njg2MSwianRpIjoiOWQ4ODM0NDItNTMwNC00OTBlLTgzYWItMTkwMDM2ZmI0ODAwIiwiaXNzIjoiaHR0cHM6Ly9zc28uc3lzdGVsb3Nwcm8uY29tL2F1dGgvcmVhbG1zL2FwcCIsImF1ZCI6Imh0dHBzOi8vc3NvLnN5c3RlbG9zcHJvLmNvbS9hdXRoL3JlYWxtcy9hcHAiLCJzdWIiOiI2MjQwZDMyZi1hNjUyLTQ3MmMtODViZi00MmNiMjdkZDI0MjAiLCJ0eXAiOiJSZWZyZXNoIiwiYXpwIjoic2FsZXNmb3JjZSIsInNlc3Npb25fc3RhdGUiOiJkZTI4NjdmYy0wNTg2LTQyNTUtOTM1My02YmJjYTExMzU3MjYiLCJzY29wZSI6Im9wZW5pZCBjdXN0b20gcHJvZmlsZSBzYWxlc2ZvcmNlIGVtYWlsIn0.7btTmnSzVhwxa-Pyj4KZtIJ3m1B0yMMzZRLWarQPVn4","token_type":"bearer","id_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0dHdQd1QzVVp3NGhCU3hnUk5naVg1TTZzdW45eEFkSkdCNk5CVHJNbWZzIn0.eyJleHAiOjE2MjU0NzA0NjEsImlhdCI6MTYyNTQ2Njg2MSwiYXV0aF90aW1lIjowLCJqdGkiOiJhNDhkYmMyYS1mZjNjLTRjMmItYTQ0My0zYTUwOTc4ZmJiZTYiLCJpc3MiOiJodHRwczovL3Nzby5zeXN0ZWxvc3Byby5jb20vYXV0aC9yZWFsbXMvYXBwIiwiYXVkIjoic2FsZXNmb3JjZSIsInN1YiI6IjYyNDBkMzJmLWE2NTItNDcyYy04NWJmLTQyY2IyN2RkMjQyMCIsInR5cCI6IklEIiwiYXpwIjoic2FsZXNmb3JjZSIsInNlc3Npb25fc3RhdGUiOiJkZTI4NjdmYy0wNTg2LTQyNTUtOTM1My02YmJjYTExMzU3MjYiLCJhY3IiOiIxIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJTd2FwbmlsIFNlbiIsImdyb3VwcyI6WyIvc2FsZXNmb3JjZS9hZG1pbmlzdHJhdG9yIl0sInByZWZlcnJlZF91c2VybmFtZSI6InN3YXBuaWwuc2VuQGNsb3VkYW5hbG9neS5jb20iLCJsb2NhbGUiOiJlbiIsImdpdmVuX25hbWUiOiJTd2FwbmlsIiwiZmFtaWx5X25hbWUiOiJTZW4iLCJlbWFpbCI6InN3YXBuaWwuc2VuQGNsb3VkYW5hbG9neS5jb20ifQ.IJyGWZIHhtH751N1JJTgzMlF9jXr15LiLfvR-OxGeRs-RR2qJDbQAbGFIFJ4TmreVU3tVdQ7wfFS4qNu5Y3ZQudGPOc6U9IUlgMS5KudurP_nVUfDDS6h1bgZN9CoaJuMqRAIgtbeX4mCOx5MbrHSEVzXhDZwica27MZiARIBEG5LVhFsJm7Spvb6FyjKrWRKnITUgCyqoi_7-Np5ASHgVKzIh6liVWXM7jJpK5ZmbCLuAfiNqCc7r7D8AXvhb10hRHggi4vst2Kw98RgogDW3n75-dFsJC-dJTZSItnRKe0alapv1p52OOUAMxLYGuDpq7ArKXPxd4DfJHcSEaDzw","not-before-policy":1610473598,"session_state":"de2867fc-0586-4255-9353-6bbca1135726","scope":"openid custom profile salesforce email"}'
      );
      res.setStatusCode(200);
      return res;
    } else if (
      body.contains(
        'grant_type=urn:ietf:params:oauth:grant-type:token-exchange'
      )
    ) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0dHdQd1QzVVp3NGhCU3hnUk5naVg1TTZzdW45eEFkSkdCNk5CVHJNbWZzIn0.eyJleHAiOjE2MjU0NzMxOTAsImlhdCI6MTYyNTQ2OTU5MCwianRpIjoiNTEyMjI3NzgtMjQ5OC00MDAwLThjNDEtNGU0OTg1YmRkMTAwIiwiaXNzIjoiaHR0cHM6Ly9zc28uc3lzdGVsb3Nwcm8uY29tL2F1dGgvcmVhbG1zL2FwcCIsImF1ZCI6WyJzYWxlc2ZvcmNlIiwiYWNjb3VudCJdLCJzdWIiOiI4NWNlNGNhZi02YmEzLTRiNDItYTMzZS1kZTk3OTdkY2RhOTMiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJzYWxlc2ZvcmNlIiwic2Vzc2lvbl9zdGF0ZSI6IjkyZTMxMWQyLThhNTItNDQ4Zi1iNzVhLTNmNjZkNDkyYzZiNyIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiIsInByb2Zlc3Npb25hbCJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiY3VzdG9tIHByb2ZpbGUgc2FsZXNmb3JjZSBlbWFpbCIsInpvbmVpbmZvIjoiQW1lcmljYS9Ub3JvbnRvIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJNb2hkIFJhaXMiLCJncm91cHMiOlsiL3NhbGVzZm9yY2UvcHJvZmVzc2lvbmFsIl0sInByZWZlcnJlZF91c2VybmFtZSI6Im1vaGQucmFpc0BjbG91ZGFuYWxvZ3kuY29tIiwibG9jYWxlIjoiZW4tdXMiLCJnaXZlbl9uYW1lIjoiTW9oZCIsImZhbWlseV9uYW1lIjoiUmFpcyIsImVtYWlsIjoibW9oZC5yYWlzQGNsb3VkYW5hbG9neS5jb20iLCJwaWN0dXJlIjoiL2FwaS92MS9hdHRhY2htZW50cy9udWxsIn0.AAHz8W0khZO4IxGQ8XiGgzgFyEOGOu1PeMiSjrZrKKPSF3am9afW8U0LTGKYszWEUKHgF-lKZ-y5mpfdKHkWUS-7RpgyZ7EYRFA5xwJbIbhKIGLsRbX_DRZiaC49SPuMuBQ_RGgmGOMIKHV2QJviRzDN6wPSGgnrXKjIuRs5xWPOqdwnUzKEs_DE_0rPurRYaN5ax9kKeKDwVq4HAvrBBCFxiExJZSzNuotJcu1eXSLm7n1MMTXoxXx3Z3sYSDtYl-755npyMb6OO_tLjnCGhX7XqZaOLK1JB1wk6421aDDC0GM5LiqchHkC7eDfIa1PAs_u1XCDUsDppCk12c-16Q","expires_in":3600,"refresh_expires_in":0,"token_type":"bearer","not-before-policy":1610473598,"session_state":"92e311d2-8a52-448f-b75a-3f66d492c6b7","scope":"custom profile salesforce email"}'
      );
      res.setStatusCode(200);
      return res;
    } else if (endpoint.contains('api/v1/users') && req.getMethod() == 'POST') {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"email":"swapnil.sen+878845@cloudanalogy.com","firstName":"Swapnil","lastName":"Sen","username":"swapnil.sen+878845@cloudanalogy.com","groups":["/default/professional"],"attributes":{"phone":[""],"locale":["en-us"],"picture":["/api/v1/attachments/undefined"],"zoneinfo":["America/Toronto"]},"credentials":[{"type":"password","temporary":false,"algorithm":"pbkdf2-sha256","hashIterations":27500,"value":"07FdPHTYig"}],"emailVerified":true,"enabled":true,"id":"c58eae6e-5d76-4c9c-af8d-a6aede11b665"}'
      );
      res.setStatusCode(200);
      return res;
    } else if (
      endpoint.contains('/api/v1/users?search=test1868687687@gmail.com') && req.getMethod() == 'GET'
    ) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('[{"id":"5ff18c1c-94ad-4ec5-a6a5-6bc091227607","createdTimestamp":1646300848407,"username":"sfdc.techqa2@gmail.com","enabled":true,"totp":false,"emailVerified":true,"firstName":"Harpreet","lastName":"Singh","email":"sfdc.techqa2@gmail.com","attributes":{"zoneinfo":["America/Toronto"],"locale":["en-us"],"phone":["null"]},"disableableCredentialTypes":[],"requiredActions":[],"notBefore":0}]');
      res.setStatusCode(200);
      return res;
    }else if (
      endpoint.contains('api/v1/users?search') && req.getMethod() == 'GET'
    ) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('[]');
      res.setStatusCode(200);
      return res;
    } else if (endpoint.contains('/api/v1/teams') && req.getMethod() == 'GET') {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '[{"id":"7d70ddfe-17ce-4b69-8c7e-9050aa8aff77","name":"Marketing User","path":"/Marketing User","subGroups":[{"id":"368f3f49-5e7f-4c89-8f6c-4eb6d0d40d92","name":"client","path":"/Marketing User/client","subGroups":[]},{"id":"dd1236ae-567e-4362-882f-128dec8c9714","name":"administrator","path":"/Marketing User/administrator","subGroups":[]},{"id":"f369ef8d-4200-4241-b5b3-2a4f0377c877","name":"professional","path":"/Marketing User/professional","subGroups":[]}]}]'
      );
      res.setStatusCode(200);
      return res;
    } else if (
      endpoint.contains('/api/v1/teams') && req.getMethod() == 'POST'
    ) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('38uy5839ejw8435674j');
      res.setStatusCode(200);
      return res;
    } else if (
      endpoint.contains('/chat/conversations-users/send') &&
      req.getMethod() == 'GET'
    ) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"id":"60f1936ad63fc7af7415d215","created_at":"2021-07-16T14:10:50.994Z","created_by":"Eduardo Caceres","name":"Multi Button ","name_fr":"nouveau modèle","touchpoint_template_id":"60dadbd52c5b62a3dadffbd8","conversations":[{"conversation_id":"60f1936bd63fc7af7415d217","completed_at":"2021-07-08T06:11:43.656Z","opened_at":"2021-07-08T06:11:43.656Z","status_touchpoint":"none","user_id":null,"user_name":"Swapnil Sen 16/07 Con 2","contact_id":"60f138a0466490af747ff833","avatarId":null,"language":"en_US"}]}'
      );
      res.setStatusCode(200);
      return res;
    } else if (
      endpoint.contains('/api/v1/touchpoints/') && req.getMethod() == 'PUT'
    ) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('[]');
      res.setStatusCode(200);
      return res;
    }else if (
      endpoint.contains('/api/v1/users/5ff18c1c-94ad-4ec5-a6a5-6bc091227607/teams') && req.getMethod() == 'GET'
    ) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('[{"id":"fa7fa8be-f63e-4e82-97a4-72f63b6b43e7","name":"professional","path":"/00D7j000000Gyd4EAC/professional"}]');
      res.setStatusCode(200);
      return res;
    }else if (
      endpoint.contains('/api/v1/touchpoints') && endpoint.contains('/clients') && req.getMethod() == 'GET'
    ) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"id":"62668d83adeb68e8fb3a2083","created_at":"2022-04-25T12:01:07.434Z","created_by":"TT Support","created_by_id":"54315e41-0acd-4a81-a49b-7ca6743e509a","name":"Meeting Preparation","name_fr":"Planifions notre rencontre","touchpoint_template_id":"622a64385235e23907355896","conversations":[{"conversation_id":"62668d83adeb68e8fb3a2084","completed_at":"2022-04-26T09:16:46Z","opened_at":"2022-04-26T09:16:46Z","status_touchpoint":"none","user_id":null,"user_name":"HR SF Mass Contact 21-4 T1 2499","contact_id":"62610b10ef5df56030141dd6","avatarId":null,"language":"en_US"},{"conversation_id":"62668d83adeb68e8fb3a2074","completed_at":"2022-04-26T09:16:46Z","opened_at":"2022-04-26T09:16:46Z","status_touchpoint":"none","user_id":null,"user_name":"HR SF Mass Contact 21-4 T1 2499","contact_id":"62610b10ef5lf56030141dd6","avatarId":null,"language":"en_US"}]}');
      res.setStatusCode(200);
      return res;
    } else {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setHeader('X-Total-Count', '2');
      res.setHeader('X-total-count', '2');
      res.setBody(
        '{ "user": { "id": "5e95dc6839a36082d", "name": "Jad Chehlawi", "deleted": false, "isAdmin": false, "userName": "telostouch_advisor", "password": "iVfG75z9CU9.lDwGySc.iTkkGWaBPRyJEq7o1EODInLbPJSf21pS5yOxta9HiuJLO33Kn3Q0kaXGqRoKs8pNn1", "salutationName": null, "firstName": "Jad", "lastName": "Chehlawi", "isActive": true, "isPortalUser": false, "isSuperAdmin": false, "title": "Advisor", "emailAddress": "nitesh+telostouch_advisor@telostouch.com", "phoneNumber": null, "gender": "", "createdAt": "2020-04-14 15:53:12", "userName2": null, "occupation": "None", "passwordGenerated": true, "integrationId": null, "integrationType": null, "integrationSource": null, "acceptedTermsOfUse": true, "acceptedTermsOfUseAt": "2020-04-14 11:54:00", "addressStreet": null, "addressCity": null, "addressState": null, "addressCountry": null, "addressPostalCode": null, "defaultTeamId": "5e95dc68455165000", "defaultTeamName": "Jad Chehlawi", "teamsIds": [ "5926fca6c9a784020", "5e95dc68455165000", "5eb5a1bfe4d45b69a", "5ea047ca503baf727", "5ea047caae48f3337", "5eea75398da5f0284", "5ef6413c4e2f9128d", "5ef6434ade485424c", "5efb6878dd44a4c96", "5efb6cd75ddaed7e4", "5f034f80427c57163", "5f343543c940c4cb6", "5f3c19f284851b1ac", "5f4aa7eba6f061112", "5f4aa9027f7751ba4", "5f50058844de005bb", "5f5027f50f0f344f8", "5f523c972ecd4edb5", "5f526a4d3121faa0a", "5f53614b8ec16621d" ], "teamsNames": { "5926fca6c9a784020": "Professionals", "5e95dc68455165000": "Jad Chehlawi", "5eb5a1bfe4d45b69a": "Eduardo Caceres", "5ea047ca503baf727": "first_name_00011375 last_name_00011375", "5ea047caae48f3337": "first_name_00024050 last_name_00024050", "5eea75398da5f0284": "Alejandro Caceres", "5ef6413c4e2f9128d": "wcww wcwrc", "5ef6434ade485424c": "qqa qa", "5efb6878dd44a4c96": "egtegt tgeetget", "5efb6cd75ddaed7e4": "wfwrf wrfwrfw", "5f034f80427c57163": "Nicky Android", "5f343543c940c4cb6": "John Smith", "5f3c19f284851b1ac": "sfhn sfv", "5f4aa7eba6f061112": "Thomas One", "5f4aa9027f7751ba4": "Timbo Set", "5f50058844de005bb": "efveqerv rve", "5f5027f50f0f344f8": "erg eg", "5f523c972ecd4edb5": "Alex Smith", "5f526a4d3121faa0a": "fhfnh qa Kemmer", "5f53614b8ec16621d": "Mohd Rais" }, "contactId": null, "contactName": null, "avatarName": null, "avatarId": null, "emailAddressList": [ "nitesh+telostouch_advisor@telostouch.com" ] }, "token": null, "language": "en_US", "announcements": []}'
      );
      res.setStatusCode(200);
      return res;
    }
  }
}