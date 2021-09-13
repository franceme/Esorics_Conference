default:: cycle
sdkInit=~/.sdkman/bin/sdkman-init.sh
docker=sudo docker
imageName=runningimage

cycle: install clean docker live

java:
	@bash -c "source $(sdkInit) && sdk ls java|grep zulu|grep 7|head -n 1|cut -d '|' -f 5-|tr --delete '|' |  sed 's/^[[:blank:]]*//;s/[[:blank:]]*$$//'| xargs -I {} bash -c 'source $(sdkInit) && yes|sdk i java {}'"
	@bash -c "source $(sdkInit) && sdk ls java|grep zulu|grep 8|head -n 1|cut -d '|' -f 5-|tr --delete '|' |  sed 's/^[[:blank:]]*//;s/[[:blank:]]*$$//'| xargs -I {} bash -c 'source $(sdkInit) && yes|sdk i java {}'"
	@bash -c "source $(sdkInit) && sdk ls java|grep adpt|grep 11|head -n 1|cut -d '|' -f 5-|tr --delete '|' |  sed 's/^[[:blank:]]*//;s/[[:blank:]]*$$//'| xargs -I {} bash -c 'source $(sdkInit) && yes|sdk i java {}'"

install:
	@$(info Installing the required dependencies)
	@$(info Following the instructions for Ubuntu at https://docs.docker.com/engine/install/ubuntu/)
	@sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
	@curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	@sudo apt-get update
	@sudo apt-get install docker-ce docker-ce-cli containerd.io

docker:
	@$(info Build the Docker file)
	$(docker) build -t $(imageName) .

live:
	@$(info Running the Docker file)
	#This exposes port 9000 from the host machine to port 8888 within the docker machine
	@$(docker) run -p 9000:8888 -e JUPYTER_ENABLE_LAB=yes -ti $(imageName) /bin/bash

clean:
	@$(info Cleaning all the Dockerfiles)
	@-$(docker) kill $$($(docker) ps -q)
	@-$(docker) rm $$($(docker) ps -a -q)
	@-$(docker) rmi $$($(docker) images -q)
