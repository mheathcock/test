# Copyright (C) 2019  Roberto Metere and Peter Carmichael, Newcastle Upon Tyne, UK
# Copyright (C) 2021  Charles Morisset, Newcastle Upon Tyne, UK
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# DESCRIPTION
#
# This web service implements the following protocol
#
#   A -> S: A,B
#   S -> A: {#K,{K}KBS}KAS
#   A -> B: {K}KBS,{#s}K
#

WEBSERVICE_TO_HACK="http://10.0.0.6/ctf_deploy/compleke/ziNuxn4fsQ"

KES="1788279208104052375212791311701435195696"

# Function to sanitize Base64 encoding
function sanitise_b64() {
  echo ${1//+/%2b}
}

# Function to extract Base64-encoded data
function get_b64_output() {
  echo $1 | cut -d ':' -f 2 | awk '{print $1}'
}

function encrypt_with_KES() {
  data="$1"
  KES="1788279208104052375212791311701435195696"

  
  encrypted_data=$(echo -n "$data" | openssl enc -aes-256-cbc -base64 -K "$KES")

  echo "$encrypted_data"
}


# Function to inject B
function injectB() {
  PAYLOAD=$(get_b64_output "$1")
  # Manipulation of the payload to send to S in the first step
  echo $(sanitise_b64 "$PAYLOAD")
}

# Function to inject A
function injectA() {
  PAYLOAD=$(get_b64_output "$1")
  # Manipulation of the payload to send to A in the second step
  echo $(sanitise_b64 "$PAYLOAD")
}


function protocol() {

  step1=$(wget -q -O - "$WEBSERVICE_TO_HACK/A.php?step=1")
  echo "$step1"

 
  encrypted_data_step2=$(encrypt_with_KES "$(injectB "$step1")")

  step2=$(wget -q -O - "$WEBSERVICE_TO_HACK/S.php?step=2&data=$encrypted_data_step2")
  echo "$step2"

  
  encrypted_data_step3=$(encrypt_with_KES "$(injectA "$step2")")

  step3=$(wget -q -O - "$WEBSERVICE_TO_HACK/A.php?step=3&data=$encrypted_data_step3")
  echo "$step3"


  encrypted_data_step4=$(encrypt_with_KES "$(injectB "$step3")")

  printf "\n$(wget -q -O - "$WEBSERVICE_TO_HACK/B.php?step=4&data=$encrypted_data_step4")\n"
}


protocol


