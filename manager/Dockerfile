# Copyright 2020 IBM Corp.
# SPDX-License-Identifier: Apache-2.0

FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY manager .
USER nonroot:nonroot

ENTRYPOINT ["/manager"]
