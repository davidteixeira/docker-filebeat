# What is Filebeat?
Filebeat is a lightweight, open source shipper for log file data. Filebeat tails logs and quickly sends this information to Elasticsearch for further parsing and enrichment.

> https://www.elastic.co/products/beats/filebeat

# Why this image?

This image uses the Docker API to collect the logs of all the running containers on the same machine and ship them to a Elasticsearch. No need to install Filebeat manually on your host or inside your images. Just use this image to create a container that's going to handle everything for you :-)


# How to use this image
Start Filebeat as follows:

```
$ docker run -d
   -v /var/run/docker.sock:/tmp/docker.sock
   -e ELASTICSEARCH_HOST=monitoring.xyz -e ELASTICSEARCH_PORT=5044 -e SHIPPER_NAME=$(hostname)
   davidteixeira/filebeat
```

Three environment variables are needed:
* `ELASTICSEARCH_HOST`: to specify on which server runs your Elasticsearch
* `ELASTICSEARCH_PORT`: to specify on which port listens your Elasticsearch for beats inputs
* `SHIPPER_NAME`: to specify the Filebeat shipper name (deafult: the container ID)

The docker-compose service definition should look as follows:
```
filebeat:
  image: davidteixeira/filebeat
  restart: unless-stopped
  volumes:
   - /var/run/docker.sock:/tmp/docker.sock
  environment:
   - ELASTICSEARCH_HOST=monitoring.xyz
   - ELASTICSEARCH_PORT=5044
   - SHIPPER_NAME=aWonderfulName
```

# User Feedback
## Issues
If you have any problems with or questions about this image, please contact me through a [GitHub issue](https://github.com/davidteixeira/docker-filebeat/issues).

## Contributing
You are invited to the [GitHub repo](https://github.com/davidteixeira/docker-filebeat) to contribute new features, fixes, or updates, large or small.
