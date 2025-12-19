// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// // Controls the active slide/image index
// final flashCastIndexProvider = StateProvider<int>((ref) => 0);

// class FlashCastManager {
//   final List<WebSocketChannel> _clients = [];

//   void addClient(WebSocketChannel client) {
//     _clients.add(client);
//     client.stream.listen(
//       (message) {}, // Listen but ignore client messages for now (one-way broadcast)
//       onDone: () => _clients.remove(client),
//       onError: (e) => _clients.remove(client),
//     );
//   }

//   // Broadcasts the new image index to all connected browsers
//   void broadcastIndex(int index) {
//     for (var client in _clients) {
//       client.sink.add('{"type": "slide", "index": $index}');
//     }
//   }

//   void closeAll() {
//     for (var client in _clients) {
//       client.sink.close();
//     }
//     _clients.clear();
//   }
// }

// final flashCastManagerProvider = Provider((ref) => FlashCastManager());














// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// final flashCastIndexProvider = StateProvider<int>((ref) => 0);

// class FlashCastManager {
//   final List<WebSocketChannel> _clients = [];
//   int _currentIndex = 0; // Track local state

//   void addClient(WebSocketChannel client) {
//     _clients.add(client);
    
//     // IMMEDIATE SYNC: Send the current slide instantly to the new client
//     client.sink.add('{"type": "slide", "index": $_currentIndex}');

//     client.stream.listen(
//       (message) {},
//       onDone: () => _clients.remove(client),
//       onError: (e) => _clients.remove(client),
//     );
//   }

//   void broadcastIndex(int index) {
//     _currentIndex = index; // Update local state
//     for (var client in _clients) {
//       // Wrap in try-catch to handle disconnected sockets safely
//       try {
//         client.sink.add('{"type": "slide", "index": $index}');
//       } catch (e) {
//         print("Error broadcasting to client: $e");
//       }
//     }
//   }

//   void closeAll() {
//     for (var client in _clients) {
//       client.sink.close();
//     }
//     _clients.clear();
//     _currentIndex = 0;
//   }
// }

// final flashCastManagerProvider = Provider((ref) => FlashCastManager());












// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// final flashCastIndexProvider = StateProvider<int>((ref) => 0);

// class FlashCastManager {
//   final List<WebSocketChannel> _clients = [];
//   int _currentIndex = 0;

//   void addClient(WebSocketChannel client) {
//     _clients.add(client);
//     // Send current state immediately
//     client.sink.add('{"type": "slide", "index": $_currentIndex}');
//     client.stream.listen(
//       (message) {},
//       onDone: () => _clients.remove(client),
//       onError: (e) => _clients.remove(client),
//     );
//   }

//   // 1. Slide Change
//   void broadcastIndex(int index) {
//     _currentIndex = index;
//     _broadcast('{"type": "slide", "index": $index}');
//   }

//   // 2. Zoom Sync (Sends Matrix4 values)
//   void broadcastZoom(List<double> matrix) {
//     _broadcast('{"type": "zoom", "matrix": $matrix}');
//   }

//   // 3. Drawing Sync (Sends X/Y coordinates 0.0-1.0 relative)
//   void broadcastDraw(double x, double y, bool isEnd) {
//     _broadcast('{"type": "draw", "x": $x, "y": $y, "end": $isEnd}');
//   }

//   // 4. Clear Canvas
//   void broadcastClear() {
//     _broadcast('{"type": "clear"}');
//   }

//   void _broadcast(String message) {
//     for (var client in _clients) {
//       try { client.sink.add(message); } catch (e) { /* Ignore disconnected */ }
//     }
//   }

//   void closeAll() {
//     for (var client in _clients) {
//       client.sink.close();
//     }
//     _clients.clear();
//     _currentIndex = 0;
//   }
// }

// final flashCastManagerProvider = Provider((ref) => FlashCastManager());









// import 'dart:typed_data';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class FlashCastManager {
//   final List<WebSocketChannel> _clients = [];
  
//   // Store the last broadcasted image to send to new joiners immediately
//   Uint8List? _lastImageFrame; 

//   void addClient(WebSocketChannel client) {
//     _clients.add(client);
    
//     // If we have a slide active, send it to the new person immediately
//     if (_lastImageFrame != null) {
//       client.sink.add(_lastImageFrame!);
//     }

//     client.stream.listen(
//       (message) {},
//       onDone: () => _clients.remove(client),
//       onError: (e) => _clients.remove(client),
//     );
//   }

//   // Broadcast a RAW Image Frame (Snapshot of PDF page or Image file)
//   void broadcastImageFrame(Uint8List imageBytes) {
//     _lastImageFrame = imageBytes;
//     for (var client in _clients) {
//       try {
//         client.sink.add(imageBytes);
//       } catch (e) {
//         print("Socket Error: $e");
//       }
//     }
//   }

//   // Broadcast Drawing Coordinates (JSON)
//   void broadcastDraw(double x, double y, bool isEnd) {
//     final msg = '{"type": "draw", "x": $x, "y": $y, "end": $isEnd}';
//     for (var client in _clients) {
//       try { client.sink.add(msg); } catch (_) {}
//     }
//   }

//   void broadcastClear() {
//     for (var client in _clients) {
//       try { client.sink.add('{"type": "clear"}'); } catch (_) {}
//     }
//   }

//   void closeAll() {
//     for (var client in _clients) {
//       client.sink.close();
//     }
//     _clients.clear();
//     _lastImageFrame = null;
//   }
// }

// final flashCastManagerProvider = Provider((ref) => FlashCastManager());



//=========================================================================================//




import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FlashCastManager {
  final List<WebSocketChannel> _clients = [];
  
  // Store the last frame to sync new joiners instantly
  Uint8List? _lastImageFrame; 

  void addClient(WebSocketChannel client) {
    _clients.add(client);
    
    // Send immediate sync frame
    if (_lastImageFrame != null) {
      client.sink.add(_lastImageFrame!);
    }

    client.stream.listen(
      (message) {},
      onDone: () => _clients.remove(client),
      onError: (e) => _clients.remove(client),
    );
  }

  // 1. Broadcast Image (Screen Share)
  void broadcastImageFrame(Uint8List imageBytes) {
    _lastImageFrame = imageBytes;
    for (var client in _clients) {
      try {
        client.sink.add(imageBytes);
      } catch (e) {
        // print("Socket Error: $e");
      }
    }
  }

  // 2. Broadcast Drawing (Pen/Highlighter)
  void broadcastDraw(double x, double y, bool isEnd) {
    final msg = '{"type": "draw", "x": $x, "y": $y, "end": $isEnd}';
    for (var client in _clients) {
      try { client.sink.add(msg); } catch (_) {}
    }
  }

  // 3. Broadcast Clear
  void broadcastClear() {
    const msg = '{"type": "clear"}';
    for (var client in _clients) {
      try { client.sink.add(msg); } catch (_) {}
    }
  }

  void closeAll() {
    for (var client in _clients) {
      client.sink.close();
    }
    _clients.clear();
    _lastImageFrame = null;
  }
}

final flashCastManagerProvider = Provider((ref) => FlashCastManager());