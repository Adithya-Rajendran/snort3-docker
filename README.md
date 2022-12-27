# snort3-docker
Create a Dockerfile to build snort3, tcmalloc, and libdaq libraries.

## Usage 

Set up the network interface you want to monitor to promiscious mode
```
ip link set $network_interface promisc on
```

Build the container image
```
docker build -t container_snort .
```

Run the container
```
docker run -it --rm --name snort --volume $(pwd)/snort/:/usr/local/etc/snort --volume $(pwd)/rules/:/usr/local/etc/rules --net=host container_snort:latest
```

## License

[GNU General Public License v3.0](LICENSE)
