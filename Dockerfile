FROM ghcr.io/cirruslabs/flutter:3.44.0 AS build

# CirrusLabs publishes the .0 image reliably; pin the actual SDK checkout to
# Flutter 3.44.8 so pubspec's Dart 3.12.2 constraint is satisfied.
RUN git -C "$FLUTTER_ROOT" fetch --depth 1 https://github.com/flutter/flutter.git 3.44.8 \
    && git -C "$FLUTTER_ROOT" checkout --force FETCH_HEAD \
    && flutter precache --web \
    && flutter --version

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --base-href=/

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
