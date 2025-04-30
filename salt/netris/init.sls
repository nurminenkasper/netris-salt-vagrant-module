/home/vagrant/netris_0.1.9_linux_amd64.tar.gz:
  file.managed:
    - source: https://netris.rocket9labs.com/download/0.1.9/netris_0.1.9_linux_amd64.tar.gz
    - makedirs: True
    - user: vagrant
    - group: vagrant
    - mode: 644
    - skip_verify: True

/home/vagrant/:
  archive.extracted:
    - source: /home/vagrant/netris_0.1.9_linux_amd64.tar.gz
    - tar_options:
      - xz
    - user: vagrant
    - group: vagrant
    - require:
      - file: /home/vagrant/netris_0.1.9_linux_amd64.tar.gz
    - clean: True
    - enforce_toplevel: False

/home/vagrant/.ssh:
  file.directory:
    - user: vagrant
    - group: vagrant
    - mode: 700
    - makedirs: True

generate netris server ssh host key:
  cmd.run:
    - name: 'ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N ""'
    - user: vagrant
    - unless: 'test -f /home/vagrant/.ssh/id_rsa'
    - require:
      - file: /home/vagrant/.ssh

/home/vagrant/.ssh/id_rsa:
  file.managed:
    - user: vagrant
    - group: vagrant
    - mode: 600
    - require:
      - cmd: generate netris server ssh host key
      - file: /home/vagrant/.ssh

/home/vagrant/.ssh/id_rsa.pub:
  file.managed:
    - user: vagrant
    - group: vagrant
    - mode: 644
    - require:
      - cmd: generate netris server ssh host key
      - file: /home/vagrant/.ssh

/etc/systemd/system/netris-server.service:
  file.managed:
    - source: salt://netris/files/netris-server.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - archive: /home/vagrant/

run netris server service:
  service.running:
    - name: netris-server
    - enable: True
    - watch:
      - file: /etc/systemd/system/netris-server.service
    - require:
      - file: /etc/systemd/system/netris-server.service
      - cmd: generate netris server ssh host key
      - archive: /home/vagrant/
      - file: /home/vagrant/.ssh/id_rsa
      - file: /home/vagrant/.ssh/id_rsa.pub