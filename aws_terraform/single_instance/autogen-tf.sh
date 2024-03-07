#!/bin/bash

pushd &>/dev/null ~/environment/aws2tf

TGIDS=$( aws ec2 describe-transit-gateways --query "TransitGateways[].TransitGatewayId" | jq .[] )

for j in ${TGIDS}; do
TGID=$( echo $J| tr -d '"' )
./aws_tf.sh -t tgw -i "$TGID"
done

VPCID=$( aws ec2 describe-vpcs --filters "Name=isDefault,Values=false" --query "Vpcs[].VpcId" | jq .[] )

# shellcheck disable=SC2034
for i in VPCID ; do
./aws_tf.sh -t vpc -i "${VPCID}" -c yes
done

./aws_tf.sh -t inst -c yes
