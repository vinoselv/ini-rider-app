import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riderapp/models/mqtt.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'dart:convert';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientWrapper {

  String serverUri = "a12ucxj1zaaa1x-ats.iot.eu-west-1.amazonaws.com";
  int port = 8883;

  MqttServerClient client;
  String topicName;
  JsonToLocationConverter jsonToLocationConverter = JsonToLocationConverter();

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  final Function(LocationData) onLocationReceivedCallback;

  MQTTClientWrapper(this.topicName, this.onLocationReceivedCallback);

  void prepareMqttClient(String topicName) async {
    await _setupMqttClient();
    await _connectClient();

    _subscribeToTopic(topicName);
  }

  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;

      // Setup the connection Message
      final connMess = MqttConnectMessage()
          .withClientIdentifier('inirider')
          .startClean();
      client.connectionMessage = connMess;

      await client.connect();

      if (client.connectionStatus.state == MqttConnectionState.connected) {
        print("Connected to AWS Successfully!");
      } else {
        return false;
      }

    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('MQTTClientWrapper::Mosquitto client connected');
    } else {
      print(
          'MQTTClientWrapper::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void _setupMqttClient() async {
    client = MqttServerClient.withPort(serverUri, 'inirider', port);
    // Set Keep-Alive
    client.keepAlivePeriod = 20;
    // Set the protocol to V3.1.1 for AWS IoT Core, if you fail to do this you will not receive a connect ack with the response code
    client.setProtocolV311();
    // logging if you wish
    client.logging(on: true);

    final context = SecurityContext.defaultContext;
    final ByteData authoritiesBytes = await rootBundle.load('assets/certs/root-CA.crt');
    context.setClientAuthoritiesBytes(authoritiesBytes.buffer.asUint8List());

    final ByteData crtData = await rootBundle.load('assets/certs/client-cert.pem');
    context.useCertificateChainBytes(crtData.buffer.asUint8List());

    final ByteData keyBytes = await rootBundle.load('assets/certs/client-private.key');
    context.usePrivateKeyBytes(keyBytes.buffer.asUint8List());
    client.securityContext = context;
    client.secure = true;

    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  void closeMqttClient() {
    client.disconnect();
  }

  void _subscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String newLocationJson =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print("MQTTClientWrapper::GOT A NEW MESSAGE $newLocationJson");
      LocationData newLocationData = _convertJsonToLocation(newLocationJson);
      if (newLocationData != null) onLocationReceivedCallback(newLocationData);
    });
  }

  LocationData _convertJsonToLocation(String newLocationJson) {
    try {
      return jsonToLocationConverter.convert(
          newLocationJson);
    } catch (exception) {
      print("Json can't be formatted ${exception.toString()}");
    }
    return null;
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
  }

  void _onDisconnected() {
    print('MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    print('MQTTClientWrapper::OnDisconnected: ' + client.connectionStatus.returnCode.name);
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
  }

}

class JsonToLocationConverter {

  LocationData convert(String input) {
    Map<String, dynamic> jsonInput = jsonDecode(input);
    return LocationData.fromMap({
      'latitude':jsonInput['state']['reported']['gnss']['v']['lat'],
      'longitude':jsonInput['state']['reported']['gnss']['v']['lng'],
    });
  }

}