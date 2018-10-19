#!/usr/bin/env bash

MY_WORKING_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}" )" )"
source ${MY_WORKING_DIR}/functions.sh

while getopts "i:" o; do
    case "${o}" in
        i)
            ISOIMAGE=$(readlink -f "$OPTARG")
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${ISOIMAGE}" ]; then
    usage
    exit -1
fi

iso_image_check ${ISOIMAGE}

CONFIGURATION="controllerstorage"
BRIDGE_INTERFACE=${BRIDGE_INTERFACE:-stxbr}
CONTROLLER=${CONTROLLER:-controller}
COMPUTE=${COMPUTE:-compute}
COMPUTE_NODES_NUMBER=${COMPUTE_NODES_NUMBER:-1}
DOMAIN_DIRECTORY=vms

bash destroy_controller_storage.sh

[ ! -d ${DOMAIN_DIRECTORY} ] && mkdir ${DOMAIN_DIRECTORY}

create_controller $CONFIGURATION $CONTROLLER $BRIDGE_INTERFACE $ISOIMAGE

for ((i=0; i<=$COMPUTE_NODES_NUMBER; i++)); do
    COMPUTE_NODE=${CONFIGURATION}-${COMPUTE}-${i}
    create_compute ${COMPUTE_NODE}
    echo $COMPUTE_NODE
done

sudo virt-manager
