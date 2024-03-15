

locals {
    
    timestamp = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"

    source_options_standard = {
        ami_name                = "packer-${local.timestamp}"
        #headless                = true
        #output_directory        = "${local.artifacts_directory}/image"

        #cpus                    = 4
        #memory                  = 8192
        #disk_size               = 130048

        #boot_wait               = "2s"
        #shutdown_timeout        = "5m"
    }

    communicator    = {
        type        = "ssh"
        username    = "ubuntu"
        password    = "ubuntu"
        timeout     = "15m"
    }

    native_build    = local.image_build == "native"
    vagrant_build   = local.image_build == "vagrant"
}

locals {
    source_options_build = merge(local.source_options_standard, local.native_build ? local.source_options_native : local.source_options_vagrant)
}

source "null" "standard" {
    communicator = "ssh"
}


build {
    name        = "native-restore"
    sources     = ["null.core"]

    provisioner "shell-local" {
        inline = [
            "sudo apt install -ansible",
            "sudo apt update --attributes",
            "chef export ${local.artifacts_directory}/--force"
        ]
    }
}

local = {
    
    chef_destination         = "/var/tmp/packer-build/chef/"
    chef_max_retries         = 10
    chef_start_retry_timeout = "30m"
    chef_attributes          = lookup(local.image_options.native, "chef_attributes", "")
    chef_keep                = lookup(local.image_options.native, "chef_keep", "false")
}

build {
    name            = "native-build"
    sources         = local.native_build ? (local.native_iso ? compact([lookup(local.native_iso_sources, local.image_provider, "")]) : compact([lookup(local.native_import_sources, local.image_provider, "")])) : ["null.core"]

    provisioner "shell" {
        script      = "${path.root}/chef/initialize.sh"
    }

    provisioner "file" {
        source      = "${local.artifacts_directory}/chef/"
        destination = local.chef_destination
    }

    provisioner "file" {
        sources     = fileset(path.cwd, "attributes.*.json")
        destination = local.chef_destination
    } 

    provisioner "shell" {
        script      = "${path.root}/chef/apply.sh"
        max_retries = local.chef_max_retries
        pause_before        = "90s"
        start_retry_timeout = local.chef_start_retry_timeout

        env = {
            JAMMY_ATTRIBUTES = local.chef_attributes
        }
    }

    provisioner "shell" {
        script              = "${path.root}/chef/cleanup.sh"
        expect_disconnect   = true

        env = {
            CHEF_KEEP       = local.chef_keep
        }
    }

    post-processor "manifest" {
        output              = "${local.artifacts_directory}/manifest.json"
    }

    post-processor "checksum" {
        checksum_types      = ["sha256"]
        output              = "${local.artifacts_directory}/checksum.{{ .ChecksumType }}"
    }
}

build {
    name = "native-test"
    sources = ["null.core"]
}

build {
    name = "native-publish"




    sources = ["null.core"]
}