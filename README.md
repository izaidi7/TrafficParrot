# MOCK service setup using Traffic Parrot

In this project, we will be setting up Traffic Parrot to simulate REST and GRPC api mock servers 



[Traffic parrot](https://trafficparrot.com/)   is an API mocking and service virtualization tool. It simulates APIs and services so that you can test your microservice without having to worry about test data set up or environment availability.

To experience Traffic Parrot locally follow these [instructions](https://trafficparrot.com/documentation/5.8.x/start.html) 

# Deploy deploy Debug Resolver mock service to k3d

1.  Pre-requisite
    
    1.  ```
        install docker
	install kubectl
        install k3d
		wget -q -O - https://raw.githubusercontent.com/rancher/k3d/master/install.sh | bash - this will install k3d in root and one default namespace created in root. to work pods in user's name space please follow the below
		k3d delete       
        ```
        Create docker login, if you don't have one
2.  Follow the k3d instructions as below:
    
    1.  ```
        k3d create \
            --publish 8080:80 \
            --publish 8443:443 \
            --workers 3 \
            --server-arg --no-deploy=traefik
        
       export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"

        #Verify k3d setup
		kubectl get pods
		kubectl config get-clusters
		kubectl get nodes 
        ```
 3. From step3, we start on mock service setup. This is the one time setup required for mock service.
    3a. Unzip the TrafficParrot.zip file
    3b. For GRPC apis, the spec will be defined in proto files. So, to create mock service, please collect the list of .proto files from 	 dev team required for your service
    3c. Typically, ALL the GRPC api based services will have main proto file. This will be main source for all the GRPC apis.
	What could be the challenge here?
	      Normally in the main proto, there will be other dependent import of proto files. like below 
	      ```
		import "github.com/lyft/protoc-gen-validate/validate/validate.proto";
		import "google/api/annotations.proto";
		import "protoc-gen-swagger/options/annotations.proto";
		```			
    3d. So for mock service setup, we need to have all the proto files with same folder structure. once you have all the proto files, 		copy them to proto folder of traffic parrot
    3e. Run the ./start.sh file in traffic parrot folder.
    3f. Locad the hostname:8080 url in the browser, and your Traffic parrot is ready.
    3g. Click on GRPC and select Add/edit option in the UI
    3g. Now the time to refer HLD to know the request and responses of the GRPC mock service
    3h. Based on proto files, you will be able to see the sample request of the service need to be mocked. example below. this is the   	request of DEBUG resolver
    ```
    {
 	 "ophid": "",
 	 "command": {
   	 "cmd": "",
   	 "args": [""],
   	 "env": [""],
   	 "workdir": ""
 	 },
  	"stdin": "",
  	"in": {
    	"namespace": "",
   	 "service": "",
   	 "index": 0,
   	 "container": ""
  	}
	}
	```
    3i. Create the response based on the request. the response can be unary or stream response. based on the design of the service
    3j. Create error usecases for all the possible GRPC error codes. While creating error usecases, keep one parameter mandaory in your 	request, based on the paramter create the error response. Example below
    
        ```
	Request
	{
  "ophid": "N123450001",
  "command": {
    "cmd": "cat",
    "args": ["/var/named/named.conf"],
    "env": [],
    "workdir": ""
  },
  "stdin": ""
}
4.  Follow the instructions to deploy **Traffic Parrot ** in k3d
    
      ```
      docker login <docker username>
	docker password
       export IMAGE=docker.io/prakashkb/trafficparrot:1.0.3       
        docker pull $IMAGE && k3d import-images $IMAGE
        cd charts
        helm install trafficparrot
       ```
        
5.  Install  **Diagnostic service**  - This actual code of Diagnostic service which is SUT (service under test)
    
    1.  ```
        # import once only
        export IMAGE=infobloxcto/atlas.onprem.diagnostic-server:<Refer the latest version of image>
        docker pull $IMAGE && k3d import-images $IMAGE
        #Edit the deploy/diagnostic.yaml to confgiure debug resolver mock service
        debugresolver:
	      enabled: true
		      address: 10.120.250.248 <External IP of Traffic parrot instance> :5552 <Non TLS port> 
        kubectl apply -f deploy/diagnostic.yaml
        
        ```
        
    2.  Test
        
        ```
        curl --request GET \
          --url http://localhost:8080/atlas-onprem-diagnostic-service/v1/remotecommands \
          
        ```
