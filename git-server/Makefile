tools:
	brew tap openresty/brew
	brew install openresty

push-ecr:
	aws ecr get-login-password --region eu-west-1 --profile=pj | docker login --username AWS --password-stdin 232619344298.dkr.ecr.eu-west-1.amazonaws.com
	docker build -t git-server .
	docker tag git-server:latest 232619344298.dkr.ecr.eu-west-1.amazonaws.com/git-server:latest
	docker push 232619344298.dkr.ecr.eu-west-1.amazonaws.com/git-server:latest
