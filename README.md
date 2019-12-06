# MOCK service setup using Traffic Parrot

In this project, we will be setting up Traffic Parrot to simulate REST and GRPC api mock servers 



[Traffic parrot](https://trafficparrot.com/)   is an API mocking and service virtualization tool. It simulates APIs and services so that you can test your microservice without having to worry about test data set up or environment availability.

To experience Traffic Parrot locally follow these [instructions](https://trafficparrot.com/documentation/5.8.x/start.html) 

# Deploy deploy Debug Resolver mock service to k3d

1.  Pre-requisite
    
    1.  ```
        install docker
        install k3d
        install kubectl
        
        ```
        Create docker login, if you don't have one
2.  Follow the k3d instructions as below:
    
    1.  ```
        k3d create \
            --publish 8080:80 \
            --publish 8443:443 \
            --workers 3 \
            --server-arg --no-deploy=traefik
        
        k3d get-kubeconfig --name='k3s-default'
        
        kubectl config use-context default
        #Verify k3d setup
		kubectl get pods
		kubectl config get-clusters
		kubectl get nodes 
        ```
 3. Collect the list of .proto files created for your service
	 For ALL the GRPC api based services will have main proto file. This will be main source for all the GRPC apis.
	 To have GRPC mock service, work with dev team and collect all the required proto files.
	  What could be the challenge here?
	      Normally in the main proto, there will be other import of proto files. like below 
	      
	      ```
			import "github.com/lyft/protoc-gen-validate/validate/validate.proto";
			import "google/api/annotations.proto";
			import "protoc-gen-swagger/options/annotations.proto";
			```
			
So for Traffic parrot, we need to have all the protofiles with same folder structure and copy them to proto folder
For Debug resolver mock service we have all the proto files.
        
4.  Follow the instructions to deploy **Traffic Parrot ** in k3d
    
      ```
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
