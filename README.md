# dart-threads-client

> Warning: The dart-threads-client library is temporarily deprecated as remote DB support not currently up-to-date with the [Textile Hub](https://docs.textile.io/hub/introduction/) and so will not work. If you are waiting for Dart support, please [see here](https://github.com/textileio/dart-textile/issues/5).

[![Made by Textile](https://img.shields.io/badge/made%20by-Textile-informational.svg?style=popout-square)](https://textile.io)
[![Chat on Slack](https://img.shields.io/badge/slack-slack.textile.io-informational.svg?style=popout-square)](https://slack.textile.io)
[![GitHub license](https://img.shields.io/github/license/textileio/dart-threads-client.svg?style=popout-square)](./LICENSE)
[![Dart CI](https://github.com/textileio/dart-threads-client/workflows/Dart%20CI/badge.svg?style=popout-square&branch=master)](https://github.com/textileio/dart-threads-client/actions?query=workflow%3A%22Dart+CI%22)
[![Pub](https://img.shields.io/pub/v/threads_client.svg?style=popout-square)](https://pub.dartlang.org/packages/threads_client)
[![Threads version](https://img.shields.io/badge/dynamic/yaml?style=popout-square&color=3527ff&label=go-threads&prefix=v&query=packages.threads_client_grpc.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Ftextileio%2Fdart-threads-client%2Fmaster%2Fpubspec.lock)](https://github.com/textileio/go-threads)
[![Build status](https://img.shields.io/github/workflow/status/textileio/dart-threads-client/test/master.svg?style=popout-square)](https://github.com/textileio/dart-threads-client/actions?query=branch%3Amaster)

> Textile's Dart client for interacting with remote Threads

Join us on our [public Slack channel](https://slack.textile.io/) for news, discussions, and status updates. [Check out our blog](https://medium.com/textileio) for the latest posts and announcements.

## Table of Contents

-   [Getting Started](#getting_started)
-   [Usage](#Usage)
-   [Development](#development)
-   [Contributing](#contributing)
-   [Changelog](#changelog)
-   [License](#license)

## Getting Started

In the `pubspec.yaml` of your project, add the following dependency:

```
dependencies:
  ...
  threads_client: "^0.x.x"
```

### Connect to a Threads Daemon

You can use Textile's hosted daemons or run your own.

##### Use hosted Threads

[Textile Threads](https://github.com/textileio/dart-textile).

##### Run your own daemon

You need to run a threads daemon available to the client.

```sh
git clone git@github.com:textileio/go-threads.git
cd go-threads
go run threadsd/main.go -debug
```

## Usage

[Read the Complete API Documentation](https://textileio.github.io/dart-threads-client/threads_client/threads_client-library.html).

### Create a DB

```dart
import 'package:threads_client/threads_client.dart' as threads;

void main(List<String> args) async {
  final client = threads.Client();
  final dbId = 'bafk7ayo2xuuafgx6ubbcn2lro3s7oixgujdda6shv4';
  final creds = threads.Creds.fromStrings(dbId);
  await client.newDB(creds);
}
```

### Run Threads using hosted Textile API

```dart
import 'package:textile/textile.dart' as textile;
import 'package:threads_client/threads_client.dart' as threads;

const APP_TOKEN = '<app token>';
const DEVICE_ID = '<uuid>';

void main(List<String> args) async {
  final config = textile.ThreadsConfig(APP_TOKEN, DEVICE_ID);
  final client = threads.Client(config: config);
  final dbId = 'bafk7ayo2xuuafgx6ubbcn2lro3s7oixgujdda6shv4';
  final creds = threads.Creds.fromStrings(dbId);
  await client.newDB(creds);
}
```

### Further examples

You can find a good overview of Client methods in the test suite.

[Threads Client Tests](https://github.com/textileio/dart-threads-client/blob/master/test/threads_client_test.dart#L53)

### Add custom metadata to requests

For example, add a custom auth token to the header of each request.

```dart
    final config = ThreadsConfig(
      host: '127.0.0.1',
      port: 6006,
      callOptionsMetaData: {
        'authorization': 'Bearer 3f2950d0-5522-4425-829f-75894e233442'
      }
    );
    // Create a new threads client
    client = Client(config);
```

## Development

### Install

Run the daemon, as above. Next, install and run the Dart `threads_client`:

```sh
git clone git@github.com:textileio/dart-threads-client.git
cd dart-threads-client
pub get
```

### Run tests

```sh
dart test/threads_client_test.dart
```

### Run example

```sh
dart example/helloworld.dart
```

## Contributing

This project is a work in progress. As such, there's a few things you can do right now to help out:

-   **Ask questions**! We'll try to help. Be sure to drop a note (on the above issue) if there is anything you'd like to work on and we'll update the issue to let others know. Also [get in touch](https://slack.textile.io) on Slack.
-   **Open issues**, [file issues](https://github.com/textileio/dart-threads-client/issues), submit pull requests!
-   **Perform code reviews**. More eyes will help a) speed the project along b) ensure quality and c) reduce possible future bugs.
-   **Take a look at the code**. Contributions here that would be most helpful are **top-level comments** about how it should look based on your understanding. Again, the more eyes the better.
-   **Add tests**. There can never be enough tests.

Before you get started, be sure to read our [contributors guide](./CONTRIBUTING.md) and our [contributor covenant code of conduct](./CODE_OF_CONDUCT.md).

## Changelog

[Changelog is published to Releases.](https://github.com/textileio/js-threads-client/releases)

## License

[MIT](LICENSE)
