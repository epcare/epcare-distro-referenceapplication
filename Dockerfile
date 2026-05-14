# syntax=docker/dockerfile:1

ARG OPENMRS_CORE_VERSION=2.8.x

### Dev Stage
FROM --platform=$BUILDPLATFORM openmrs/openmrs-core:${OPENMRS_CORE_VERSION}-dev-amazoncorretto-21 AS dev

WORKDIR /openmrs_distro

ARG MVN_ARGS="-s /usr/share/maven/ref/settings-docker.xml -U -P distro"
ARG MVN_COMMAND="install"

COPY pom.xml ./
COPY distro ./distro/

ARG CACHE_BUST

RUN --mount=type=secret,id=m2settings,target=/usr/share/maven/ref/settings-docker.xml \
  echo "Building distro on build platform..." && \
  echo "MVN command: mvn $MVN_ARGS $MVN_COMMAND -e" && \
  mvn $MVN_ARGS $MVN_COMMAND -e -X

RUN mkdir -p /openmrs/distribution/openmrs_core
RUN cp /openmrs_distro/distro/target/sdk-distro/web/openmrs_core/openmrs.war /openmrs/distribution/openmrs_core/
RUN cp /openmrs_distro/distro/target/sdk-distro/web/openmrs-distro.properties /openmrs/distribution/
RUN cp -R /openmrs_distro/distro/target/sdk-distro/web/openmrs_modules /openmrs/distribution/openmrs_modules/
RUN cp -R /openmrs_distro/distro/target/sdk-distro/web/openmrs_owas /openmrs/distribution/openmrs_owas/
RUN cp -R /openmrs_distro/distro/target/sdk-distro/web/openmrs_config /openmrs/distribution/openmrs_config/

RUN mvn $MVN_ARGS clean


### Run Stage
FROM --platform=$TARGETPLATFORM openmrs/openmrs-core:${OPENMRS_CORE_VERSION}-amazoncorretto-21

COPY --from=dev /openmrs/distribution/openmrs_core/openmrs.war /openmrs/distribution/openmrs_core/
COPY --from=dev /openmrs/distribution/openmrs-distro.properties /openmrs/distribution/
COPY --from=dev /openmrs/distribution/openmrs_modules /openmrs/distribution/openmrs_modules
COPY --from=dev /openmrs/distribution/openmrs_owas /openmrs/distribution/openmrs_owas
COPY --from=dev /openmrs/distribution/openmrs_config /openmrs/distribution/openmrs_config