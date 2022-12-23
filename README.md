# snort3-docker (NOT COMPLETED)
Create a Dockerfile to build snort3, tcmalloc, and libdaq libraries.

## Usage 

Build the container image
```
docker build -t Container_snort .
```

Run the container
```
docker run -it --rm --name snort3 --volume $(pwd)/rules/:/usr/local/etc/snort --net=host Container_snort:latest
```

## License

[GNU General Public License v3.0](LICENSE)
