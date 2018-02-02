#!/bin/bash

cd /opt/docker/api/var/git/mackerel && \
git fetch origin 'refs/heads/*:refs/heads/*' && \
git update-server-info
