# syntax=docker/dockerfile:1

### Dev Stage - Use Amazon Linux 2023 for newer GLIBC (needed for Node.js)
FROM amazoncorretto:21 AS dev

# Install dependencies needed for OpenMRS SDK
RUN dnf install -y maven && \
    dnf clean all

# Create OpenMRS directory structure needed for copy operations
RUN mkdir -p /openmrs/distribution/openmrs_core

WORKDIR /openmrs_distro

ARG MVN_ARGS="-U -P distro"
ARG MVN_COMMAND="install"

COPY pom.xml ./
COPY distro ./distro/

ARG CACHE_BUST

RUN --mount=type=secret,id=m2settings,target=/root/.m2/settings.xml \
  if [ "$(arch)" != "x86_64" ]; then \
  FINAL_MVN_ARGS="$FINAL_MVN_ARGS -Dmaven.deploy.skip=true"; \
  fi && \
  echo "Running: mvn $FINAL_MVN_ARGS $MVN_COMMAND -e" && \
  mvn $FINAL_MVN_ARGS $MVN_COMMAND -e -X

RUN cp /openmrs_distro/distro/target/sdk-distro/web/openmrs_core/openmrs.war /openmrs/distribution/openmrs_core/
RUN cp /openmrs_distro/distro/target/sdk-distro/web/openmrs-distro.properties /openmrs/distribution/
RUN cp -R /openmrs_distro/distro/target/sdk-distro/web/openmrs_modules /openmrs/distribution/openmrs_modules/
RUN cp -R /openmrs_distro/distro/target/sdk-distro/web/openmrs_owas /openmrs/distribution/openmrs_owas/
RUN cp -R /openmrs_distro/distro/target/sdk-distro/web/openmrs_config /openmrs/distribution/openmrs_config/

RUN mvn $MVN_ARGS clean


### Run Stage
FROM openmrs/openmrs-core:2.8.x-amazoncorretto-21

COPY --from=dev /openmrs/distribution/openmrs_core/openmrs.war /openmrs/distribution/openmrs_core/
COPY --from=dev /openmrs/distribution/openmrs-distro.properties /openmrs/distribution/
COPY --from=dev /openmrs/distribution/openmrs_modules /openmrs/distribution/openmrs_modules
COPY --from=dev /openmrs/distribution/openmrs_owas /openmrs/distribution/openmrs_owas
COPY --from=dev /openmrs/distribution/openmrs_config /openmrs/distribution/openmrs_config