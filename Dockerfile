# syntax=docker/dockerfile:1

### Dev Stage
FROM openmrs/openmrs-core:2.8.x-dev-amazoncorretto-21 AS dev

WORKDIR /openmrs_distro

# --------------------------------------------------
# Install Node 20 (Required for OpenMRS O3 SPA build)
# --------------------------------------------------
RUN yum install -y curl \
  && curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - \
  && yum install -y nodejs \
  && node -v \
  && npm -v

ARG MVN_ARGS_SETTINGS="-s /usr/share/maven/ref/settings-docker.xml -U -P distro"
ARG MVN_ARGS="install"

# Copy build files
COPY pom.xml ./
COPY distro ./distro/

ARG CACHE_BUST

# Build the distro (deploy only on amd64)
RUN --mount=type=secret,id=m2settings,target=/usr/share/maven/ref/settings-docker.xml \
  if [[ "$MVN_ARGS" != "deploy" || "$(arch)" = "x86_64" ]]; then \
  mvn $MVN_ARGS_SETTINGS $MVN_ARGS; \
  else \
  mvn $MVN_ARGS_SETTINGS install; \
  fi

# Copy build artifacts
RUN cp /openmrs_distro/distro/target/sdk-distro/web/openmrs_core/openmrs.war /openmrs/distribution/openmrs_core/

RUN cp /openmrs_distro/distro/target/sdk-distro/web/openmrs-distro.properties /openmrs/distribution/
RUN cp -R /openmrs_distro/distro/target/sdk-distro/web/openmrs_modules /openmrs/distribution/openmrs_modules/
RUN cp -R /openmrs_distro/distro/target/sdk-distro/web/openmrs_owas /openmrs/distribution/openmrs_owas/
RUN cp -R /openmrs_distro/distro/target/sdk-distro/web/openmrs_config /openmrs/distribution/openmrs_config/

# Clean up
RUN mvn $MVN_ARGS_SETTINGS clean


### Run Stage
FROM openmrs/openmrs-core:2.8.x-amazoncorretto-21

COPY --from=dev /openmrs/distribution/openmrs_core/openmrs.war /openmrs/distribution/openmrs_core/
COPY --from=dev /openmrs/distribution/openmrs-distro.properties /openmrs/distribution/
COPY --from=dev /openmrs/distribution/openmrs_modules /openmrs/distribution/openmrs_modules
COPY --from=dev /openmrs/distribution/openmrs_owas /openmrs/distribution/openmrs_owas
COPY --from=dev /openmrs/distribution/openmrs_config /openmrs/distribution/openmrs_config