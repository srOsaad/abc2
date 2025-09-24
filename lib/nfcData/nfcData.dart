import 'dart:convert';
import 'dart:typed_data';

import 'dart:typed_data';


class NFCData {
  static Uint8List generateReadCommand(
    Uint8List idm, {
    int serviceCode = 0x220F,
    int numberOfBlocksToRead = 10,
    int startBlockNumber = 0,
}) {
  // Convert the service code into a byte array (little-endian)
  Uint8List serviceCodeList = Uint8List(2);
  serviceCodeList[0] = (serviceCode & 0xFF);
  serviceCodeList[1] = ((serviceCode >> 8) & 0xFF);

  // Prepare the block list elements
  Uint8List blockListElements = Uint8List(numberOfBlocksToRead * 2);
  for (int i = 0; i < numberOfBlocksToRead; i++) {
    blockListElements[i * 2] = 0x80; // Control byte
    blockListElements[i * 2 + 1] = startBlockNumber + i; // Block number
  }

  // Calculate the total length of the command
  int commandLength = 14 + blockListElements.length;
  Uint8List command = Uint8List(commandLength);
  int idx = 0;

  // Populate the command array step by step
  command[idx++] = commandLength; // Command length
  command[idx++] = 0x06; // Command code

  // Copy the IDM into the command array
  command.setRange(idx, idx + idm.length, idm);
  idx += idm.length;

  command[idx++] = 0x01; // Some fixed byte (e.g., command type)
  command[idx++] = serviceCodeList[0]; // Service code low byte
  command[idx++] = serviceCodeList[1]; // Service code high byte
  command[idx++] = numberOfBlocksToRead; // Number of blocks to read

  // Copy the block list elements into the command array
  command.setRange(idx, idx + blockListElements.length, blockListElements);

  return command;
}
  static List<int> array= [34, 6, 1, 39, 213, 7, 202, 242, 112, 191, 1, 15, 34, 10, 128, 0, 128, 1, 128, 2, 128, 3, 128, 4, 128, 5, 128, 6, 128, 7, 128, 8, 128, 9],
  array2 = [34, 6, 1, 70, 66, 69, 69, 70, 155, 255, 1, 15, 34, 10, 128, 0, 128, 1, 128, 2, 128, 3, 128, 4, 128, 5, 128, 6, 128, 7, 128, 8, 128, 9];
  static Uint8List nfcUint8(bool _isOn) {
    return Uint8List.fromList(_isOn? array : array2);
  }
}
