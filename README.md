# concourse-tasks

These are some sample tasks and a pipeline for translationCore.

## Prerequisits

1. [concourse](https://concourse-ci.org/)!
1. install [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository)
1. install [docker-compose](https://docs.docker.com/compose/install/)
1. install concourse on either:
   1. [a server](https://github.com/concourse/concourse-docker)
   1. [your local machine](https://concourse-ci.org/) (see quick start guide)
1. install [fly](https://github.com/concourse/concourse/releases) on your local machine so you can interact with concourse.
1. deploy the pipeline with fly!

## Features

You can view the latest builds at http://tc-builds.door43.org.

## NGINX Reverse Proxy

When running on a server you'll likely want to run concourse behind a domain. You can do this by setting up a reverse proxy in nginx.

```
upstream concourse {
	server localhost:8080;
}

server {
	listen 80:
	listen [::]:80;

	server_name [your.domain.name];

	location / {
		proxy_set_header Host $http_host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For proxy_add_x_forwarded_for;

		proxy_redirect off;
		proxy_pass http://concourse;
	}
}
```
You could also add ssl support in the above configuration if desired.

> Note: concourse will still be accessible from port `8080` directly. If this is undesirable you can set up a firewall on your server.

## Deployment

> These deployment instructions assume you are running concourse on your local machine.
> If you are running it on a server simply change the target url to the appropriate address and port.

First log into your concourse instance
```
fly -t ci.door43 login -n tc -c https://ci.door43.org
```
> TRICKY: if you are logging in to any team other than `main` you'll need to specify the team name
> with `-n` as shown above.

Then deploy the pipeline
```
fly -t ci.door43 set-pipeline -p translation-core -c tc-pipeline.yml -l credentials.yml
```

> NOTE: you'll need to provide the correct credentials inside `credentials.yml` see [Parameters](https://concoursetutorial.com/basics/parameters/) for details.

To debug a job
```
fly -t ci.door43 intercept -j map/build
```

To execute a single job without running the entire pipeline
```
fly -t ci.door43 execute --config tasks/unit-tests.yml
```

## Docker Image

This repo contains the Docker image used in jobs.
If you update the image you can deploy it again with the following commands:

```bash
docker build -t neutrinog/concourse-tasks .
docker push neutrinog/concourse-tasks:latest
```

## Server Maintenance

You may need to clean up old docker images from time to time (like after rebooting, or hard restarting concourse).
See [this gist](https://gist.github.com/bastman/5b57ddb3c11942094f8d0a97d461b430) for details.

Concourse can be stopped/started by running
```
docker-compose stop
docker-compose start
```

As a convenience we have added a restart script to our concourse installation. Running `restart_concourse_d43.sh` will shut down concourse, prune the docker containers, and start it up again.

### Upgrading

In order to upgrade concourse you must:
1. log into the ci.door43.org server
2. edit `docker-compose.yml` and update the concourse image to the desired version.
3. perform any additional (if any) steps indicated in the release notes.
3. run `restart_concourse_d43.sh`

A list of concourse releases can be found at https://github.com/concourse/concourse/releases.

## Worker Maintenance

Workers will stall periodically (hopefully this will be [fixed](https://github.com/concourse/concourse/issues/1457) soon).
To remedy stalled workers you can prune them.

* `fly -t ci.door43 workers` lists workers and indicates which ones are stalled
* `fly -t ci.door43 prune-worker -w <stalled-worker-id>` will prune a stalled worker.

> Note: it may take a few minutes for new workers to start after you have pruned stalled workers.
