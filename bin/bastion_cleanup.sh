#!/bin/sh

for key in abdelrahman-ali.id_rsa.pub amr-emaish.id_rsa.pub kareem-saad.id_rsa.pub marwa-maher.id_rsa.pub mazen-ali.id_rsa.pub mostafa-elhefnawy.id_rsa.pub
do 
  for portal in olx-eg olx-lb olx-om olx-qa olx-sa olx-bh olx-kw olx-jo
  do
    for env in dev stage prod 
    do
  	  aws s3 rm "s3://${portal}-${env}-storage/bastion/${key}" --profile "${portal}-${env}"
    done 
  done
  
done