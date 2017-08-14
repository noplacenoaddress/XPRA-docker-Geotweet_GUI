sudo pacman -S virtualgl
sudo pacman -S opencv
pacaur -S libhdf5
pacaur -S xpra-winswitch

docker system prune
docker container kill x11-xpra
docker container rm x11-xpra
docker build --rm -t geotweeter .
docker run -p 2020:22 -d --name x11-xpra `docker images -q geotweeter`
docker exec -i x11-xpra /bin/bash -c 'cat > /home/docker/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
cat /dev/null > ~/.ssh/known_hosts
xpra --ssh="ssh -p 2020" attach ssh:docker@localhost:100

ssh -p 2020 docker@localhost DISPLAY=:100 setxkbmap -layout es
ssh -p 2020 docker@localhost DISPLAY=:100 geotweet

