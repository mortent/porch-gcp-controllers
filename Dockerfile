# Copyright 2022 - 2024 The kpt and Nephio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.23.0-bookworm AS builder

WORKDIR /go/src

# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
COPY go.mod go.sum ./

RUN echo "Downloading required modules ..." \
 && go mod download

ENV CGO_ENABLED=0

COPY . ./

RUN CGO_ENABLED=0 go build -o /porch-gcp-controllers -v .

FROM gcr.io/distroless/static
WORKDIR /data
COPY --from=builder /porch-gcp-controllers /porch-gcp-controllers

ENTRYPOINT ["/porch-gcp-controllers"]
