// import 'dart:async';
// // import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/history_manager.dart';
// import 'package:flash_share/logic/trust_manager.dart';
// // import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mime/mime.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart' as shelf_io;
// import 'package:shelf_multipart/form_data.dart';
// import 'package:shelf_multipart/multipart.dart';
// import 'package:shelf_web_socket/shelf_web_socket.dart';

// final serverStatusProvider = StateProvider<ServerStatus>((ref) => ServerStatus.idle);
// final serverUrlProvider = StateProvider<String?>((ref) => null);
// final selectedFilesProvider = StateProvider<List<File>?>((ref) => []);
// final serverPinProvider = StateProvider<String?>((ref) => null);
// final clipboardProvider = StateProvider<String>((ref) => "");
// final downloadPathProvider = StateProvider<String?>((ref) => null);
// final isFlashCastActiveProvider = StateProvider<bool>((ref) => false);

// enum ServerStatus { idle, active, error }

// class ServerManager {
//   HttpServer? _server;
//   final Ref ref;
//   String? _currentPin;
//   final TrustManager _trustManager = TrustManager();

//   ServerManager(this.ref);

//   Future<void> startServer() async {
//     try {
//       final ip = await NetworkInfo().getWifiIP();
//       if (ip == null) throw Exception("No Network connection found.");

//       await _initDownloadDirectory();

//       _currentPin = (Random().nextInt(9000) + 1000).toString();
//       ref.read(serverPinProvider.notifier).state = _currentPin;
//       ref.read(clipboardProvider.notifier).state = ""; 

//       final handler = const Pipeline()
//           .addMiddleware(logRequests())
//           .addMiddleware(_securityMiddleware) 
//           .addHandler(_handleRequest);

//       _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
//       ref.read(serverUrlProvider.notifier).state = 'http://$ip:${_server!.port}';
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.active;
      
//     } catch (e) {
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.error;
//       rethrow;
//     }
//   }

//   Future<Response> _handleRequest(Request request) async {
//     final path = request.url.path;
//     final currentFiles = ref.read(selectedFilesProvider) ?? [];
//     final isFlashCast = ref.read(isFlashCastActiveProvider);

//     if (path == 'ws') {
//       return webSocketHandler((webSocket) {
//         ref.read(flashCastManagerProvider).addClient(webSocket);
//       })(request);
//     }

//     if (path == 'login') {
//       if (request.method == 'POST') {
//           final body = await request.readAsString();
//           final params = Uri.splitQueryString(body);
//           final inputPin = params['pin'];
//           final trust = params['trust'] == 'on';

//           if (_currentPin != null && inputPin == _currentPin) {
//             String token;
//             int maxAge;
//             if (trust) {
//               token = _trustManager.addTrustedDevice(request.headers['user-agent'] ?? 'Unknown');
//               maxAge = 31536000;
//             } else {
//               token = _currentPin!;
//               maxAge = 86400;
//             }
//             return Response.ok('OK', headers: {'Set-Cookie': 'auth=$token; Max-Age=$maxAge; Path=/'});
//           }
//           return Response.forbidden('Invalid PIN');
//       }
//       return _serveLoginPage(); 
//     }

//     if (path.isEmpty || path == '/') {
//       return isFlashCast ? _serveFlashCastViewer(currentFiles) : _serveDashboard(currentFiles);
//     }

//     if (request.url.pathSegments.isNotEmpty && request.url.pathSegments.first == 'file') {
//       final index = int.tryParse(request.url.pathSegments[1]);
//       if (index != null && index >= 0 && index < currentFiles.length) {
//         return _serveFile(currentFiles[index], request);
//       }
//     }

//     if (path == 'upload' && request.method == 'POST') return await _handleFileUpload(request);

//     if (path == 'clipboard') {
//       if (request.method == 'GET') return Response.ok(ref.read(clipboardProvider));
//       if (request.method == 'POST') {
//         final text = await request.readAsString();
//         ref.read(clipboardProvider.notifier).state = text;
//         return Response.ok('Synced');
//       }
//     }
//     return Response.notFound('Not Found');
//   }

//   Future<void> _initDownloadDirectory() async {
//     Directory? saveDir;
//     if (Platform.isAndroid) {
//       saveDir = Directory('/storage/emulated/0/Download/FlashShare');
//     } else {
//       saveDir = await getDownloadsDirectory(); 
//       if (saveDir == null) {
//          final docDir = await getApplicationDocumentsDirectory();
//          saveDir = Directory('${docDir.path}/FlashShare_Received');
//       } else {
//          saveDir = Directory('${saveDir.path}/FlashShare_Received');
//       }
//     }
//     if (!saveDir.existsSync()) saveDir.createSync(recursive: true);
//     ref.read(downloadPathProvider.notifier).state = saveDir.path;
//   }

//   Handler _securityMiddleware(Handler innerHandler) {
//     return (Request request) {
//       final path = request.url.path;
//       if (path == 'login' || path.startsWith('assets')) return innerHandler(request);
//       final cookies = request.headers['cookie'];
//       if (cookies != null) {
//         final cookieMap = Map.fromEntries(cookies.split(';').map((e) {
//             final split = e.trim().split('=');
//             return MapEntry(split[0], split.length > 1 ? split[1] : '');
//         }));
//         final token = cookieMap['auth'];
//         if (token != null) {
//           if (token == _currentPin) return innerHandler(request);
//           if (_trustManager.isTrusted(token)) return innerHandler(request);
//         }
//       }
//       return Response.found('/login');
//     };
//   }

//   Future<Response> _handleFileUpload(Request request) async {
//     if (!request.isMultipart) return Response.badRequest(body: 'Not multipart');
//     final path = ref.read(downloadPathProvider);
//     if (path == null) return Response.internalServerError(body: "Save path not initialized");
//     final saveDir = Directory(path);

//     await for (final formData in request.multipartFormData) {
//       if (formData.filename != null) {
//         final file = File('${saveDir.path}/${formData.filename}');
//         final sink = file.openWrite();
//         await sink.addStream(formData.part);
//         await sink.close();
//         ref.read(historyProvider.notifier).addEntry(
//           fileName: formData.filename!, type: 'received', size: await file.length()
//         );
//       }
//     }
//     return Response.ok('File Uploaded Successfully');
//   }

//   Response _serveFile(File file, Request request) {
//     final length = file.lengthSync();
//     final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
//     final range = request.headers['range'];

//     if (range != null && range.startsWith('bytes=')) {
//       final parts = range.substring(6).split('-');
//       final start = int.parse(parts[0]);
//       final end = parts.length > 1 && parts[1].isNotEmpty ? int.parse(parts[1]) : length - 1;
//       if (start >= length) return Response(416, body: 'Range Not Satisfiable');
//       final stream = file.openRead(start, end + 1);
//       if (start == 0) {
//         ref.read(historyProvider.notifier).addEntry(
//           fileName: file.path.split(Platform.pathSeparator).last, type: 'sent', size: length
//         );
//       }
//       return Response(206, body: stream, headers: {
//           'Content-Type': mimeType, 'Content-Length': (end - start + 1).toString(),
//           'Content-Range': 'bytes $start-$end/$length', 'Accept-Ranges': 'bytes',
//       });
//     }
//     ref.read(historyProvider.notifier).addEntry(
//       fileName: file.path.split(Platform.pathSeparator).last, type: 'sent', size: length
//     );
//     return Response.ok(file.openRead(), headers: {
//         'Content-Type': mimeType, 'Content-Length': length.toString(), 'Accept-Ranges': 'bytes',
//     });
//   }

//   Response _serveLoginPage() {
//     const html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;display:flex;justify-content:center;align-items:center;height:100vh;margin:0}.card{background:rgba(255,255,255,0.1);padding:40px;border-radius:20px;text-align:center;backdrop-filter:blur(10px)}input[type=number]{padding:10px;font-size:20px;text-align:center;border-radius:10px;border:none;width:150px;margin-bottom:10px}button{background:#00D2FF;border:none;padding:10px 30px;border-radius:20px;font-weight:bold;cursor:pointer;margin-top:15px}label{display:block;margin-top:10px;font-size:14px;cursor:pointer}</style></head><body><div class="card"><h2>🔒 Secure Connection</h2><p>Enter PIN shown on Host Device</p><form onsubmit="event.preventDefault();login()"><input type="number" id="pin" placeholder="0000" required><br><label><input type="checkbox" id="trust"> Trust this device (Skip PIN next time)</label><button type="submit">Connect</button></form></div><script>async function login(){const pin=document.getElementById('pin').value;const trust=document.getElementById('trust').checked;const res=await fetch('/login',{method:'POST',body:'pin='+pin+'&trust='+(trust?'on':'off')});if(res.ok)window.location.href='/';else alert('Wrong PIN');}</script></body></html>''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   Response _serveDashboard(List<File> files) {
//     final galleryHtml = files.isEmpty 
//       ? '<div style="grid-column:1/-1;text-align:center;padding:40px;color:rgba(255,255,255,0.5)"><h3>No files shared yet</h3><p>Tap "Add Files" on the host device to share.</p></div>' 
//       : files.asMap().entries.map((entry) { 
//         final index = entry.key; final name = entry.value.path.split(Platform.pathSeparator).last; final mime = lookupMimeType(entry.value.path) ?? ''; final isImage = mime.startsWith('image/'); final isVideo = mime.startsWith('video/'); String preview = isImage ? '<img src="/file/$index" class="preview">' : (isVideo ? '<video src="/file/$index" class="preview" controls></video>' : '<div class="icon">📄</div>'); return '''<div class="card">$preview<div class="info"><div class="name">$name</div><a href="/file/$index" download="$name" class="btn">Download</a></div></div>'''; 
//     }).join('');

//     final html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;padding:20px;max-width:1200px;margin:0 auto}h1,h3{color:#00D2FF}.tabs{display:flex;gap:10px;margin-bottom:20px}.tab{padding:10px 20px;background:rgba(255,255,255,0.1);border-radius:20px;cursor:pointer}.tab.active{background:#00D2FF;color:black;font-weight:bold}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:15px}.card{background:rgba(255,255,255,0.1);border-radius:12px;overflow:hidden;backdrop-filter:blur(10px)}.preview{width:100%;height:120px;object-fit:cover;background:black}video.preview{object-fit:contain}.icon{font-size:50px;text-align:center;padding:20px}.info{padding:10px;text-align:center}.name{font-size:12px;margin-bottom:8px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.btn{background:#00D2FF;color:black;text-decoration:none;padding:5px 15px;border-radius:20px;font-size:12px;display:inline-block}.section{display:none}.section.active{display:block}.dropzone{border:2px dashed #00D2FF;padding:40px;text-align:center;border-radius:20px;cursor:pointer}textarea{width:100%;height:150px;background:rgba(0,0,0,0.3);color:#00D2FF;border:1px solid #00D2FF;border-radius:10px;padding:10px;font-size:16px}</style></head><body><div style="display:flex;justify-content:space-between;align-items:center"><h1>⚡ FlashShare</h1><button onclick="location.reload()" class="btn">Refresh</button></div><div class="tabs"><div class="tab active" onclick="switchTab('gallery')">Download</div><div class="tab" onclick="switchTab('upload')">Upload</div><div class="tab" onclick="switchTab('clipboard')">Clipboard</div></div><div id="gallery" class="section active"><div class="grid">$galleryHtml</div></div><div id="upload" class="section"><div class="dropzone" id="dropzone"><h3>Drag & Drop files here</h3><p>or click to browse</p><input type="file" id="fileInput" multiple style="display:none"></div><div id="uploadStatus" style="margin-top:20px;color:#00D2FF"></div></div><div id="clipboard" class="section"><h3>Universal Clipboard</h3><p>Type here to sync with connected device.</p><textarea id="clipText" placeholder="Type or paste text here..."></textarea></div><script>function switchTab(id){document.querySelectorAll('.section').forEach(el=>el.classList.remove('active'));document.querySelectorAll('.tab').forEach(el=>el.classList.remove('active'));document.getElementById(id).classList.add('active');event.target.classList.add('active')}const dropzone=document.getElementById('dropzone');const fileInput=document.getElementById('fileInput');dropzone.onclick=()=>fileInput.click();fileInput.onchange=()=>uploadFiles(fileInput.files);dropzone.ondragover=(e)=>{e.preventDefault();dropzone.style.background='rgba(255,255,255,0.1)'};dropzone.ondragleave=()=>dropzone.style.background='transparent';dropzone.ondrop=(e)=>{e.preventDefault();uploadFiles(e.dataTransfer.files)};async function uploadFiles(files){const status=document.getElementById('uploadStatus');status.innerText="Uploading "+files.length+" files...";const formData=new FormData();for(let i=0;i<files.length;i++)formData.append('files',files[i]);try{await fetch('/upload',{method:'POST',body:formData});status.innerText="✅ Upload Complete! Files saved.";}catch(e){status.innerText="❌ Upload Failed";}}const clipText=document.getElementById('clipText');let isTyping=false;let timeout;clipText.oninput=()=>{isTyping=true;clearTimeout(timeout);timeout=setTimeout(()=>isTyping=false,2000);fetch('/clipboard',{method:'POST',body:clipText.value});};setInterval(async()=>{if(isTyping)return;const res=await fetch('/clipboard');const text=await res.text();if(text!==clipText.value)clipText.value=text;},1000);</script></body></html>''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   Response _serveFlashCastViewer(List<File> files) {
//     const html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;background:black;display:flex;justify-content:center;align-items:center;height:100vh;overflow:hidden}#slide{max-width:100%;max-height:100%;transition:opacity 0.3s}.waiting{color:white;font-family:sans-serif;text-align:center}</style></head><body><div id="container"><h1 class="waiting">🔴 Live FlashCast<br>Waiting for presenter...</h1></div><script>const ws=new WebSocket('ws://'+window.location.host+'/ws');const container=document.getElementById('container');ws.onmessage=(event)=>{const data=JSON.parse(event.data);if(data.type==='slide'){container.innerHTML=`<img id="slide" src="/file/\${data.index}">`}};ws.onclose=()=>{container.innerHTML='<h1 class="waiting">Disconnected</h1>'};</script></body></html>''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   void stopServer() {
//     _server?.close(force: true);
//     ref.read(flashCastManagerProvider).closeAll();
//     ref.read(serverStatusProvider.notifier).state = ServerStatus.idle;
//     ref.read(serverUrlProvider.notifier).state = null;
//     ref.read(serverPinProvider.notifier).state = null;
//     ref.read(isFlashCastActiveProvider.notifier).state = false;
//   }
// }

// final serverManagerProvider = Provider((ref) => ServerManager(ref));












// import 'dart:async';
// // import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/history_manager.dart';
// import 'package:flash_share/logic/trust_manager.dart';
// // import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mime/mime.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart' as shelf_io;
// import 'package:shelf_multipart/form_data.dart';
// import 'package:shelf_multipart/multipart.dart';
// import 'package:shelf_web_socket/shelf_web_socket.dart';

// final serverStatusProvider = StateProvider<ServerStatus>((ref) => ServerStatus.idle);
// final serverUrlProvider = StateProvider<String?>((ref) => null);
// final selectedFilesProvider = StateProvider<List<File>?>((ref) => []);
// final serverPinProvider = StateProvider<String?>((ref) => null);
// final clipboardProvider = StateProvider<String>((ref) => "");
// final downloadPathProvider = StateProvider<String?>((ref) => null);
// final isFlashCastActiveProvider = StateProvider<bool>((ref) => false);

// enum ServerStatus { idle, active, error }

// class ServerManager {
//   HttpServer? _server;
//   final Ref ref;
//   String? _currentPin;
//   final TrustManager _trustManager = TrustManager();

//   ServerManager(this.ref);

//   Future<void> startServer() async {
//     try {
//       final ip = await NetworkInfo().getWifiIP();
//       if (ip == null) throw Exception("No Network connection found.");

//       await _initDownloadDirectory();

//       _currentPin = (Random().nextInt(9000) + 1000).toString();
//       ref.read(serverPinProvider.notifier).state = _currentPin;
//       ref.read(clipboardProvider.notifier).state = ""; 

//       final handler = const Pipeline()
//           .addMiddleware(logRequests())
//           .addMiddleware(_securityMiddleware) 
//           .addHandler(_handleRequest);

//       _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
//       ref.read(serverUrlProvider.notifier).state = 'http://$ip:${_server!.port}';
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.active;
      
//     } catch (e) {
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.error;
//       rethrow;
//     }
//   }

//   Future<Response> _handleRequest(Request request) async {
//     final path = request.url.path;
//     final currentFiles = ref.read(selectedFilesProvider) ?? [];
//     final isFlashCast = ref.read(isFlashCastActiveProvider);

//     if (path == 'ws') {
//       return webSocketHandler((webSocket) {
//         ref.read(flashCastManagerProvider).addClient(webSocket);
//       })(request);
//     }

//     if (path == 'login') {
//       if (request.method == 'POST') {
//           final body = await request.readAsString();
//           final params = Uri.splitQueryString(body);
//           final inputPin = params['pin'];
//           final trust = params['trust'] == 'on';

//           if (_currentPin != null && inputPin == _currentPin) {
//             String token;
//             int maxAge;
//             if (trust) {
//               token = _trustManager.addTrustedDevice(request.headers['user-agent'] ?? 'Unknown');
//               maxAge = 31536000;
//             } else {
//               token = _currentPin!;
//               maxAge = 86400;
//             }
//             return Response.ok('OK', headers: {'Set-Cookie': 'auth=$token; Max-Age=$maxAge; Path=/'});
//           }
//           return Response.forbidden('Invalid PIN');
//       }
//       return _serveLoginPage(); 
//     }

//     if (path.isEmpty || path == '/') {
//       return isFlashCast ? _serveFlashCastViewer(currentFiles) : _serveDashboard(currentFiles);
//     }

//     // Serve file for FlashCast or Download
//     if (request.url.pathSegments.isNotEmpty && request.url.pathSegments.first == 'file') {
//       final index = int.tryParse(request.url.pathSegments[1]);
//       if (index != null && index >= 0 && index < currentFiles.length) {
//         // Simple File Serve without Range for FlashCast efficiency, or reuse existing logic
//         return _serveFile(currentFiles[index], request);
//       }
//     }

//     if (path == 'upload' && request.method == 'POST') return await _handleFileUpload(request);

//     if (path == 'clipboard') {
//       if (request.method == 'GET') return Response.ok(ref.read(clipboardProvider));
//       if (request.method == 'POST') {
//         final text = await request.readAsString();
//         ref.read(clipboardProvider.notifier).state = text;
//         return Response.ok('Synced');
//       }
//     }
//     return Response.notFound('Not Found');
//   }

//   Future<void> _initDownloadDirectory() async {
//     Directory? saveDir;
//     if (Platform.isAndroid) {
//       saveDir = Directory('/storage/emulated/0/Download/FlashShare');
//     } else {
//       saveDir = await getDownloadsDirectory(); 
//       if (saveDir == null) {
//          final docDir = await getApplicationDocumentsDirectory();
//          saveDir = Directory('${docDir.path}/FlashShare_Received');
//       } else {
//          saveDir = Directory('${saveDir.path}/FlashShare_Received');
//       }
//     }
//     if (!saveDir.existsSync()) saveDir.createSync(recursive: true);
//     ref.read(downloadPathProvider.notifier).state = saveDir.path;
//   }

//   Handler _securityMiddleware(Handler innerHandler) {
//     return (Request request) {
//       final path = request.url.path;
//       if (path == 'login' || path.startsWith('assets')) return innerHandler(request);
//       final cookies = request.headers['cookie'];
//       if (cookies != null) {
//         final cookieMap = Map.fromEntries(cookies.split(';').map((e) {
//             final split = e.trim().split('=');
//             return MapEntry(split[0], split.length > 1 ? split[1] : '');
//         }));
//         final token = cookieMap['auth'];
//         if (token != null) {
//           if (token == _currentPin) return innerHandler(request);
//           if (_trustManager.isTrusted(token)) return innerHandler(request);
//         }
//       }
//       return Response.found('/login');
//     };
//   }

//   Future<Response> _handleFileUpload(Request request) async {
//     if (!request.isMultipart) return Response.badRequest(body: 'Not multipart');
//     final path = ref.read(downloadPathProvider);
//     if (path == null) return Response.internalServerError(body: "Save path not initialized");
//     final saveDir = Directory(path);

//     await for (final formData in request.multipartFormData) {
//       if (formData.filename != null) {
//         final file = File('${saveDir.path}/${formData.filename}');
//         final sink = file.openWrite();
//         await sink.addStream(formData.part);
//         await sink.close();
//         ref.read(historyProvider.notifier).addEntry(
//           fileName: formData.filename!, type: 'received', size: await file.length()
//         );
//       }
//     }
//     return Response.ok('File Uploaded Successfully');
//   }

//   Response _serveFile(File file, Request request) {
//     final length = file.lengthSync();
//     final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
//     final range = request.headers['range'];

//     if (range != null && range.startsWith('bytes=')) {
//       final parts = range.substring(6).split('-');
//       final start = int.parse(parts[0]);
//       final end = parts.length > 1 && parts[1].isNotEmpty ? int.parse(parts[1]) : length - 1;
//       if (start >= length) return Response(416, body: 'Range Not Satisfiable');
//       final stream = file.openRead(start, end + 1);
      
//       // Don't log history for partial requests (avoids spam during streaming)
//       return Response(206, body: stream, headers: {
//           'Content-Type': mimeType, 'Content-Length': (end - start + 1).toString(),
//           'Content-Range': 'bytes $start-$end/$length', 'Accept-Ranges': 'bytes',
//       });
//     }
    
//     // Log history for full requests
//     ref.read(historyProvider.notifier).addEntry(
//       fileName: file.path.split(Platform.pathSeparator).last, type: 'sent', size: length
//     );
    
//     return Response.ok(file.openRead(), headers: {
//         'Content-Type': mimeType, 'Content-Length': length.toString(), 'Accept-Ranges': 'bytes',
//     });
//   }

//   Response _serveLoginPage() {
//     const html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;display:flex;justify-content:center;align-items:center;height:100vh;margin:0}.card{background:rgba(255,255,255,0.1);padding:40px;border-radius:20px;text-align:center;backdrop-filter:blur(10px)}input[type=number]{padding:10px;font-size:20px;text-align:center;border-radius:10px;border:none;width:150px;margin-bottom:10px}button{background:#00D2FF;border:none;padding:10px 30px;border-radius:20px;font-weight:bold;cursor:pointer;margin-top:15px}label{display:block;margin-top:10px;font-size:14px;cursor:pointer}</style></head><body><div class="card"><h2>🔒 Secure Connection</h2><p>Enter PIN shown on Host Device</p><form onsubmit="event.preventDefault();login()"><input type="number" id="pin" placeholder="0000" required><br><label><input type="checkbox" id="trust"> Trust this device (Skip PIN next time)</label><button type="submit">Connect</button></form></div><script>async function login(){const pin=document.getElementById('pin').value;const trust=document.getElementById('trust').checked;const res=await fetch('/login',{method:'POST',body:'pin='+pin+'&trust='+(trust?'on':'off')});if(res.ok)window.location.href='/';else alert('Wrong PIN');}</script></body></html>''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   Response _serveDashboard(List<File> files) {
//     final galleryHtml = files.isEmpty 
//       ? '<div style="grid-column:1/-1;text-align:center;padding:40px;color:rgba(255,255,255,0.5)"><h3>No files shared yet</h3><p>Tap "Add Files" on the host device to share.</p></div>' 
//       : files.asMap().entries.map((entry) { 
//         final index = entry.key; final name = entry.value.path.split(Platform.pathSeparator).last; final mime = lookupMimeType(entry.value.path) ?? ''; final isImage = mime.startsWith('image/'); final isVideo = mime.startsWith('video/'); String preview = isImage ? '<img src="/file/$index" class="preview">' : (isVideo ? '<video src="/file/$index" class="preview" controls></video>' : '<div class="icon">📄</div>'); return '''<div class="card">$preview<div class="info"><div class="name">$name</div><a href="/file/$index" download="$name" class="btn">Download</a></div></div>'''; 
//     }).join('');

//     // Replaced __GALLERY_CONTENT__ with actual galleryHtml
//     final dashboardHtml = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;padding:20px;max-width:1200px;margin:0 auto}h1,h3{color:#00D2FF}.tabs{display:flex;gap:10px;margin-bottom:20px}.tab{padding:10px 20px;background:rgba(255,255,255,0.1);border-radius:20px;cursor:pointer}.tab.active{background:#00D2FF;color:black;font-weight:bold}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:15px}.card{background:rgba(255,255,255,0.1);border-radius:12px;overflow:hidden;backdrop-filter:blur(10px)}.preview{width:100%;height:120px;object-fit:cover;background:black}video.preview{object-fit:contain}.icon{font-size:50px;text-align:center;padding:20px}.info{padding:10px;text-align:center}.name{font-size:12px;margin-bottom:8px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.btn{background:#00D2FF;color:black;text-decoration:none;padding:5px 15px;border-radius:20px;font-size:12px;display:inline-block}.section{display:none}.section.active{display:block}.dropzone{border:2px dashed #00D2FF;padding:40px;text-align:center;border-radius:20px;cursor:pointer}textarea{width:100%;height:150px;background:rgba(0,0,0,0.3);color:#00D2FF;border:1px solid #00D2FF;border-radius:10px;padding:10px;font-size:16px}</style></head><body><div style="display:flex;justify-content:space-between;align-items:center"><h1>⚡ FlashShare</h1><button onclick="location.reload()" class="btn">Refresh</button></div><div class="tabs"><div class="tab active" onclick="switchTab('gallery')">Download</div><div class="tab" onclick="switchTab('upload')">Upload</div><div class="tab" onclick="switchTab('clipboard')">Clipboard</div></div><div id="gallery" class="section active"><div class="grid">$galleryHtml</div></div><div id="upload" class="section"><div class="dropzone" id="dropzone"><h3>Drag & Drop files here</h3><p>or click to browse</p><input type="file" id="fileInput" multiple style="display:none"></div><div id="uploadStatus" style="margin-top:20px;color:#00D2FF"></div></div><div id="clipboard" class="section"><h3>Universal Clipboard</h3><p>Type here to sync with connected device.</p><textarea id="clipText" placeholder="Type or paste text here..."></textarea></div><script>function switchTab(id){document.querySelectorAll('.section').forEach(el=>el.classList.remove('active'));document.querySelectorAll('.tab').forEach(el=>el.classList.remove('active'));document.getElementById(id).classList.add('active');event.target.classList.add('active')}const dropzone=document.getElementById('dropzone');const fileInput=document.getElementById('fileInput');dropzone.onclick=()=>fileInput.click();fileInput.onchange=()=>uploadFiles(fileInput.files);dropzone.ondragover=(e)=>{e.preventDefault();dropzone.style.background='rgba(255,255,255,0.1)'};dropzone.ondragleave=()=>dropzone.style.background='transparent';dropzone.ondrop=(e)=>{e.preventDefault();uploadFiles(e.dataTransfer.files)};async function uploadFiles(files){const status=document.getElementById('uploadStatus');status.innerText="Uploading "+files.length+" files...";const formData=new FormData();for(let i=0;i<files.length;i++)formData.append('files',files[i]);try{await fetch('/upload',{method:'POST',body:formData});status.innerText="✅ Upload Complete! Files saved.";}catch(e){status.innerText="❌ Upload Failed";}}const clipText=document.getElementById('clipText');let isTyping=false;let timeout;clipText.oninput=()=>{isTyping=true;clearTimeout(timeout);timeout=setTimeout(()=>isTyping=false,2000);fetch('/clipboard',{method:'POST',body:clipText.value});};setInterval(async()=>{if(isTyping)return;const res=await fetch('/clipboard');const text=await res.text();if(text!==clipText.value)clipText.value=text;},1000);</script></body></html>''';
    
//     return Response.ok(dashboardHtml, headers: {'Content-Type': 'text/html'});
//   }

//   // --- UPDATED FLASHCAST VIEWER ---
//   Response _serveFlashCastViewer(List<File> files) {
//     const html = '''
//       <!DOCTYPE html>
//       <html>
//       <head>
//         <meta name="viewport" content="width=device-width, initial-scale=1">
//         <style>
//           body { margin:0; background:black; display:flex; justify-content:center; align-items:center; height:100vh; overflow:hidden; font-family:sans-serif; }
//           #content { width:100%; height:100%; display:flex; justify-content:center; align-items:center; }
//           img { max-width:100%; max-height:100%; object-fit:contain; }
//           iframe { width:100%; height:100%; border:none; }
//           .waiting { color:white; text-align:center; animation: pulse 2s infinite; }
//           @keyframes pulse { 0% { opacity:0.5; } 50% { opacity:1; } 100% { opacity:0.5; } }
//         </style>
//       </head>
//       <body>
//         <div id="content">
//           <h1 class="waiting">🔴 Live FlashCast<br>Connecting...</h1>
//         </div>
//         <script>
//           const ws = new WebSocket('ws://' + window.location.host + '/ws');
//           const content = document.getElementById('content');
          
//           ws.onmessage = (event) => {
//             const data = JSON.parse(event.data);
//             if (data.type === 'slide') {
//               const url = "/file/" + data.index;
//               content.innerHTML = `<img src="\${url}" onerror="this.style.display='none'; document.getElementById('pdf-frame').style.display='block'">
//                                    <iframe id="pdf-frame" src="\${url}" style="display:none"></iframe>`;
//             }
//           };
//           ws.onclose = () => { content.innerHTML = '<h1 class="waiting">Presentation Ended</h1>'; };
//         </script>
//       </body>
//       </html>
//     ''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   void stopServer() {
//     _server?.close(force: true);
//     ref.read(flashCastManagerProvider).closeAll();
//     ref.read(serverStatusProvider.notifier).state = ServerStatus.idle;
//     ref.read(serverUrlProvider.notifier).state = null;
//     ref.read(serverPinProvider.notifier).state = null;
//     ref.read(isFlashCastActiveProvider.notifier).state = false;
//   }
// }

// final serverManagerProvider = Provider((ref) => ServerManager(ref));












// import 'dart:async';
// // import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/history_manager.dart';
// import 'package:flash_share/logic/trust_manager.dart';
// // import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mime/mime.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart' as shelf_io;
// import 'package:shelf_multipart/form_data.dart';
// import 'package:shelf_multipart/multipart.dart';
// import 'package:shelf_web_socket/shelf_web_socket.dart';

// final serverStatusProvider = StateProvider<ServerStatus>((ref) => ServerStatus.idle);
// final serverUrlProvider = StateProvider<String?>((ref) => null);
// final selectedFilesProvider = StateProvider<List<File>?>((ref) => []);
// final serverPinProvider = StateProvider<String?>((ref) => null);
// final clipboardProvider = StateProvider<String>((ref) => "");
// final downloadPathProvider = StateProvider<String?>((ref) => null);
// final isFlashCastActiveProvider = StateProvider<bool>((ref) => false);

// enum ServerStatus { idle, active, error }

// class ServerManager {
//   HttpServer? _server;
//   final Ref ref;
//   String? _currentPin;
//   final TrustManager _trustManager = TrustManager();

//   ServerManager(this.ref);

//   Future<void> startServer() async {
//     try {
//       final ip = await NetworkInfo().getWifiIP();
//       if (ip == null) throw Exception("No Network connection found.");

//       await _initDownloadDirectory();

//       _currentPin = (Random().nextInt(9000) + 1000).toString();
//       ref.read(serverPinProvider.notifier).state = _currentPin;
//       ref.read(clipboardProvider.notifier).state = ""; 

//       final handler = const Pipeline()
//           .addMiddleware(logRequests())
//           .addMiddleware(_securityMiddleware) 
//           .addHandler(_handleRequest);

//       _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
//       ref.read(serverUrlProvider.notifier).state = 'http://$ip:${_server!.port}';
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.active;
      
//     } catch (e) {
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.error;
//       rethrow;
//     }
//   }

//   Future<Response> _handleRequest(Request request) async {
//     final path = request.url.path;
//     final currentFiles = ref.read(selectedFilesProvider) ?? [];
//     final isFlashCast = ref.read(isFlashCastActiveProvider);

//     if (path == 'ws') {
//       return webSocketHandler((webSocket) {
//         ref.read(flashCastManagerProvider).addClient(webSocket);
//       })(request);
//     }

//     if (path == 'login') {
//       if (request.method == 'POST') {
//           final body = await request.readAsString();
//           final params = Uri.splitQueryString(body);
//           final inputPin = params['pin'];
//           final trust = params['trust'] == 'on';

//           if (_currentPin != null && inputPin == _currentPin) {
//             String token;
//             int maxAge;
//             if (trust) {
//               token = _trustManager.addTrustedDevice(request.headers['user-agent'] ?? 'Unknown');
//               maxAge = 31536000;
//             } else {
//               token = _currentPin!;
//               maxAge = 86400;
//             }
//             return Response.ok('OK', headers: {'Set-Cookie': 'auth=$token; Max-Age=$maxAge; Path=/'});
//           }
//           return Response.forbidden('Invalid PIN');
//       }
//       return _serveLoginPage(); 
//     }

//     if (path.isEmpty || path == '/') {
//       return isFlashCast ? _serveFlashCastViewer(currentFiles) : _serveDashboard(currentFiles);
//     }

//     if (request.url.pathSegments.isNotEmpty && request.url.pathSegments.first == 'file') {
//       final index = int.tryParse(request.url.pathSegments[1]);
//       if (index != null && index >= 0 && index < currentFiles.length) {
//         return _serveFile(currentFiles[index], request);
//       }
//     }

//     if (path == 'upload' && request.method == 'POST') return await _handleFileUpload(request);

//     if (path == 'clipboard') {
//       if (request.method == 'GET') return Response.ok(ref.read(clipboardProvider));
//       if (request.method == 'POST') {
//         final text = await request.readAsString();
//         ref.read(clipboardProvider.notifier).state = text;
//         return Response.ok('Synced');
//       }
//     }
//     return Response.notFound('Not Found');
//   }

//   // ... (Keep _initDownloadDirectory, _securityMiddleware, _handleFileUpload) ...
//   Future<void> _initDownloadDirectory() async {
//     Directory? saveDir;
//     if (Platform.isAndroid) {
//       saveDir = Directory('/storage/emulated/0/Download/FlashShare');
//     } else {
//       saveDir = await getDownloadsDirectory(); 
//       if (saveDir == null) {
//          final docDir = await getApplicationDocumentsDirectory();
//          saveDir = Directory('${docDir.path}/FlashShare_Received');
//       } else {
//          saveDir = Directory('${saveDir.path}/FlashShare_Received');
//       }
//     }
//     if (!saveDir.existsSync()) saveDir.createSync(recursive: true);
//     ref.read(downloadPathProvider.notifier).state = saveDir.path;
//   }

//   Handler _securityMiddleware(Handler innerHandler) {
//     return (Request request) {
//       final path = request.url.path;
//       if (path == 'login' || path.startsWith('assets')) return innerHandler(request);
//       final cookies = request.headers['cookie'];
//       if (cookies != null) {
//         final cookieMap = Map.fromEntries(cookies.split(';').map((e) {
//             final split = e.trim().split('=');
//             return MapEntry(split[0], split.length > 1 ? split[1] : '');
//         }));
//         final token = cookieMap['auth'];
//         if (token != null) {
//           if (token == _currentPin) return innerHandler(request);
//           if (_trustManager.isTrusted(token)) return innerHandler(request);
//         }
//       }
//       return Response.found('/login');
//     };
//   }

//   Future<Response> _handleFileUpload(Request request) async {
//     if (!request.isMultipart) return Response.badRequest(body: 'Not multipart');
//     final path = ref.read(downloadPathProvider);
//     if (path == null) return Response.internalServerError(body: "Save path not initialized");
//     final saveDir = Directory(path);

//     await for (final formData in request.multipartFormData) {
//       if (formData.filename != null) {
//         final file = File('${saveDir.path}/${formData.filename}');
//         final sink = file.openWrite();
//         await sink.addStream(formData.part);
//         await sink.close();
//         ref.read(historyProvider.notifier).addEntry(
//           fileName: formData.filename!, type: 'received', size: await file.length()
//         );
//       }
//     }
//     return Response.ok('File Uploaded Successfully');
//   }

//   Response _serveFile(File file, Request request) {
//     final length = file.lengthSync();
//     final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
//     final range = request.headers['range'];

//     if (range != null && range.startsWith('bytes=')) {
//       final parts = range.substring(6).split('-');
//       final start = int.parse(parts[0]);
//       final end = parts.length > 1 && parts[1].isNotEmpty ? int.parse(parts[1]) : length - 1;
//       if (start >= length) return Response(416, body: 'Range Not Satisfiable');
//       final stream = file.openRead(start, end + 1);
//       return Response(206, body: stream, headers: {
//           'Content-Type': mimeType, 'Content-Length': (end - start + 1).toString(),
//           'Content-Range': 'bytes $start-$end/$length', 'Accept-Ranges': 'bytes',
//       });
//     }
    
//     // Only log if not casting to avoid spam
//     if (!ref.read(isFlashCastActiveProvider)) {
//       ref.read(historyProvider.notifier).addEntry(
//         fileName: file.path.split(Platform.pathSeparator).last, type: 'sent', size: length
//       );
//     }
//     return Response.ok(file.openRead(), headers: {
//         'Content-Type': mimeType, 'Content-Length': length.toString(), 'Accept-Ranges': 'bytes',
//     });
//   }

//   Response _serveLoginPage() {
//     const html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;display:flex;justify-content:center;align-items:center;height:100vh;margin:0}.card{background:rgba(255,255,255,0.1);padding:40px;border-radius:20px;text-align:center;backdrop-filter:blur(10px)}input[type=number]{padding:10px;font-size:20px;text-align:center;border-radius:10px;border:none;width:150px;margin-bottom:10px}button{background:#00D2FF;border:none;padding:10px 30px;border-radius:20px;font-weight:bold;cursor:pointer;margin-top:15px}label{display:block;margin-top:10px;font-size:14px;cursor:pointer}</style></head><body><div class="card"><h2>🔒 Secure Connection</h2><p>Enter PIN shown on Host Device</p><form onsubmit="event.preventDefault();login()"><input type="number" id="pin" placeholder="0000" required><br><label><input type="checkbox" id="trust"> Trust this device (Skip PIN next time)</label><button type="submit">Connect</button></form></div><script>async function login(){const pin=document.getElementById('pin').value;const trust=document.getElementById('trust').checked;const res=await fetch('/login',{method:'POST',body:'pin='+pin+'&trust='+(trust?'on':'off')});if(res.ok)window.location.href='/';else alert('Wrong PIN');}</script></body></html>''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   Response _serveDashboard(List<File> files) {
//     // Reuse existing dashboard logic
//     final galleryHtml = files.isEmpty ? '<div style="grid-column:1/-1;text-align:center;padding:40px;color:rgba(255,255,255,0.5)"><h3>No files shared yet</h3></div>' : files.asMap().entries.map((entry) { final index = entry.key; final name = entry.value.path.split(Platform.pathSeparator).last; final mime = lookupMimeType(entry.value.path) ?? ''; final isImage = mime.startsWith('image/'); final isVideo = mime.startsWith('video/'); String preview = isImage ? '<img src="/file/$index" class="preview">' : (isVideo ? '<video src="/file/$index" class="preview" controls></video>' : '<div class="icon">📄</div>'); return '''<div class="card">$preview<div class="info"><div class="name">$name</div><a href="/file/$index" download="$name" class="btn">Download</a></div></div>'''; }).join('');
//     final html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;padding:20px;max-width:1200px;margin:0 auto}h1,h3{color:#00D2FF}.tabs{display:flex;gap:10px;margin-bottom:20px}.tab{padding:10px 20px;background:rgba(255,255,255,0.1);border-radius:20px;cursor:pointer}.tab.active{background:#00D2FF;color:black;font-weight:bold}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:15px}.card{background:rgba(255,255,255,0.1);border-radius:12px;overflow:hidden;backdrop-filter:blur(10px)}.preview{width:100%;height:120px;object-fit:cover;background:black}video.preview{object-fit:contain}.icon{font-size:50px;text-align:center;padding:20px}.info{padding:10px;text-align:center}.name{font-size:12px;margin-bottom:8px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.btn{background:#00D2FF;color:black;text-decoration:none;padding:5px 15px;border-radius:20px;font-size:12px;display:inline-block}.section{display:none}.section.active{display:block}.dropzone{border:2px dashed #00D2FF;padding:40px;text-align:center;border-radius:20px;cursor:pointer}textarea{width:100%;height:150px;background:rgba(0,0,0,0.3);color:#00D2FF;border:1px solid #00D2FF;border-radius:10px;padding:10px;font-size:16px}</style></head><body><div style="display:flex;justify-content:space-between;align-items:center"><h1>⚡ FlashShare</h1><button onclick="location.reload()" class="btn">Refresh</button></div><div class="tabs"><div class="tab active" onclick="switchTab('gallery')">Download</div><div class="tab" onclick="switchTab('upload')">Upload</div><div class="tab" onclick="switchTab('clipboard')">Clipboard</div></div><div id="gallery" class="section active"><div class="grid">$galleryHtml</div></div><div id="upload" class="section"><div class="dropzone" id="dropzone"><h3>Drag & Drop files here</h3><p>or click to browse</p><input type="file" id="fileInput" multiple style="display:none"></div><div id="uploadStatus" style="margin-top:20px;color:#00D2FF"></div></div><div id="clipboard" class="section"><h3>Universal Clipboard</h3><p>Type here to sync with connected device.</p><textarea id="clipText" placeholder="Type or paste text here..."></textarea></div><script>function switchTab(id){document.querySelectorAll('.section').forEach(el=>el.classList.remove('active'));document.querySelectorAll('.tab').forEach(el=>el.classList.remove('active'));document.getElementById(id).classList.add('active');event.target.classList.add('active')}const dropzone=document.getElementById('dropzone');const fileInput=document.getElementById('fileInput');dropzone.onclick=()=>fileInput.click();fileInput.onchange=()=>uploadFiles(fileInput.files);dropzone.ondragover=(e)=>{e.preventDefault();dropzone.style.background='rgba(255,255,255,0.1)'};dropzone.ondragleave=()=>dropzone.style.background='transparent';dropzone.ondrop=(e)=>{e.preventDefault();uploadFiles(e.dataTransfer.files)};async function uploadFiles(files){const status=document.getElementById('uploadStatus');status.innerText="Uploading "+files.length+" files...";const formData=new FormData();for(let i=0;i<files.length;i++)formData.append('files',files[i]);try{await fetch('/upload',{method:'POST',body:formData});status.innerText="✅ Upload Complete! Files saved.";}catch(e){status.innerText="❌ Upload Failed";}}const clipText=document.getElementById('clipText');let isTyping=false;let timeout;clipText.oninput=()=>{isTyping=true;clearTimeout(timeout);timeout=setTimeout(()=>isTyping=false,2000);fetch('/clipboard',{method:'POST',body:clipText.value});};setInterval(async()=>{if(isTyping)return;const res=await fetch('/clipboard');const text=await res.text();if(text!==clipText.value)clipText.value=text;},1000);</script></body></html>''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   // --- UPDATED FLASHCAST VIEWER (Supports Zoom & Draw) ---
//   Response _serveFlashCastViewer(List<File> files) {
//     const html = '''
//       <!DOCTYPE html>
//       <html>
//       <head>
//         <meta name="viewport" content="width=device-width, initial-scale=1">
//         <style>
//           body { margin:0; background:black; height:100vh; overflow:hidden; touch-action:none; display:flex; justify-content:center; align-items:center; }
//           #stage { position:relative; width:100%; height:100%; display:flex; justify-content:center; align-items:center; }
//           #slide { max-width:100%; max-height:100%; transform-origin: 0 0; transition: transform 0.1s linear; }
//           #drawCanvas { position:absolute; top:0; left:0; width:100%; height:100%; pointer-events:none; }
//           iframe { width:100%; height:100%; border:none; }
//           .waiting { color:white; position:absolute; top:50%; left:50%; transform:translate(-50%, -50%); text-align:center; font-family:sans-serif; }
//         </style>
//       </head>
//       <body>
//         <h1 id="status" class="waiting">🔴 Connecting...</h1>
//         <div id="stage">
//           <img id="slide" style="display:none">
//           <iframe id="pdf-frame" style="display:none"></iframe>
//           <canvas id="drawCanvas"></canvas>
//         </div>
//         <script>
//           const ws = new WebSocket('ws://' + window.location.host + '/ws');
//           const slide = document.getElementById('slide');
//           const frame = document.getElementById('pdf-frame');
//           const canvas = document.getElementById('drawCanvas');
//           const ctx = canvas.getContext('2d');
//           const status = document.getElementById('status');
          
//           // Resize Canvas
//           function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
//           window.onresize = resize;
//           resize();

//           ws.onmessage = (event) => {
//             const data = JSON.parse(event.data);
//             status.style.display = 'none';

//             if (data.type === 'slide') {
//               const url = "/file/" + data.index;
//               // Check extension via URL string (rough check) or wait for load
//               // Reset State
//               ctx.clearRect(0, 0, canvas.width, canvas.height);
//               slide.style.transform = 'translate(0px, 0px) scale(1)';
              
//               // Try Image first
//               slide.src = url;
//               slide.style.display = 'block';
//               frame.style.display = 'none';
//               slide.onerror = () => {
//                 // Fallback to PDF/Iframe
//                 slide.style.display = 'none';
//                 frame.src = url;
//                 frame.style.display = 'block';
//               };
//             }
            
//             if (data.type === 'zoom') {
//               // Matrix4 from Flutter is [scaleX, skewX, transX, ...] column major
//               // CSS matrix3d is also column major.
//               // Note: Flutter matrix might need slight adjustment for center origin
//               const m = data.matrix;
//               // Simple 2D transform approximation: scale and translate
//               // matrix(scaleX, skewY, skewX, scaleY, translateX, translateY)
//               // Flutter Matrix4 indices: 0=scaleX, 5=scaleY, 12=transX, 13=transY
//               // But browser might handle full matrix3d better
//               if(slide.style.display !== 'none') {
//                  slide.style.transform = `matrix3d(\${m.join(',')})`;
//               }
//             }

//             if (data.type === 'draw') {
//               const x = data.x * canvas.width;
//               const y = data.y * canvas.height;
              
//               ctx.lineWidth = 4;
//               ctx.lineCap = 'round';
//               ctx.strokeStyle = '#FFFF00'; // Highlighter Yellow
              
//               if (data.end) {
//                 ctx.beginPath(); // Reset path
//               } else {
//                 ctx.lineTo(x, y);
//                 ctx.stroke();
//                 ctx.beginPath();
//                 ctx.moveTo(x, y);
//               }
//             }

//             if (data.type === 'clear') {
//               ctx.clearRect(0, 0, canvas.width, canvas.height);
//             }
//           };
//           ws.onclose = () => { status.style.display = 'block'; status.innerText = 'Disconnected'; };
//         </script>
//       </body>
//       </html>
//     ''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   void stopServer() {
//     _server?.close(force: true);
//     ref.read(flashCastManagerProvider).closeAll();
//     ref.read(serverStatusProvider.notifier).state = ServerStatus.idle;
//     ref.read(serverUrlProvider.notifier).state = null;
//     ref.read(serverPinProvider.notifier).state = null;
//     ref.read(isFlashCastActiveProvider.notifier).state = false;
//   }
// }

// final serverManagerProvider = Provider((ref) => ServerManager(ref));













// import 'dart:async';
// // import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:flash_share/logic/flashcast_manager.dart';
// // import 'package:flash_share/logic/history_manager.dart';
// import 'package:flash_share/logic/trust_manager.dart';
// // import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:mime/mime.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart' as shelf_io;
// // import 'package:shelf_multipart/form_data.dart';
// import 'package:shelf_web_socket/shelf_web_socket.dart';

// final serverStatusProvider = StateProvider<ServerStatus>((ref) => ServerStatus.idle);
// final serverUrlProvider = StateProvider<String?>((ref) => null);
// final selectedFilesProvider = StateProvider<List<File>?>((ref) => []);
// final serverPinProvider = StateProvider<String?>((ref) => null);
// final clipboardProvider = StateProvider<String>((ref) => "");
// final downloadPathProvider = StateProvider<String?>((ref) => null);
// final isFlashCastActiveProvider = StateProvider<bool>((ref) => false);

// enum ServerStatus { idle, active, error }

// class ServerManager {
//   HttpServer? _server;
//   final Ref ref;
//   String? _currentPin;
//   final TrustManager _trustManager = TrustManager();

//   ServerManager(this.ref);

//   Future<void> startServer() async {
//     try {
//       final ip = await NetworkInfo().getWifiIP();
//       if (ip == null) throw Exception("No Network connection found.");

//       await _initDownloadDirectory();

//       _currentPin = (Random().nextInt(9000) + 1000).toString();
//       ref.read(serverPinProvider.notifier).state = _currentPin;
//       ref.read(clipboardProvider.notifier).state = ""; 

//       final handler = const Pipeline()
//           .addMiddleware(logRequests())
//           .addMiddleware(_securityMiddleware) 
//           .addHandler(_handleRequest);

//       _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
//       ref.read(serverUrlProvider.notifier).state = 'http://$ip:${_server!.port}';
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.active;
      
//     } catch (e) {
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.error;
//       rethrow;
//     }
//   }

//   Future<Response> _handleRequest(Request request) async {
//     final path = request.url.path;
//     final isFlashCast = ref.read(isFlashCastActiveProvider);

//     // --- WEBSOCKET ---
//     if (path == 'ws') {
//       return webSocketHandler((webSocket) {
//         ref.read(flashCastManagerProvider).addClient(webSocket);
//       })(request);
//     }

//     // --- LOGIN ---
//     if (path == 'login') {
//       if (request.method == 'POST') {
//           final body = await request.readAsString();
//           final params = Uri.splitQueryString(body);
//           if (_currentPin != null && params['pin'] == _currentPin) {
//             String token = _currentPin!;
//             if (params['trust'] == 'on') {
//                token = _trustManager.addTrustedDevice(request.headers['user-agent'] ?? 'Unknown');
//             }
//             // Cookie valid for 1 year if trusted, else 1 day
//             return Response.ok('OK', headers: {'Set-Cookie': 'auth=$token; Max-Age=${params['trust']=='on' ? 31536000 : 86400}; Path=/'});
//           }
//           return Response.forbidden('Invalid PIN');
//       }
//       return _serveLoginPage(); 
//     }

//     // --- ROOT ---
//     if (path.isEmpty || path == '/') {
//       return isFlashCast ? _serveFlashCastViewer() : _serveDashboard(ref.read(selectedFilesProvider) ?? []);
//     }

//     // --- STANDARD FILE SERVING ---
//     if (request.url.pathSegments.isNotEmpty && request.url.pathSegments.first == 'file') {
//       final index = int.tryParse(request.url.pathSegments[1]);
//       final files = ref.read(selectedFilesProvider) ?? [];
//       if (index != null && index >= 0 && index < files.length) {
//         return _serveFile(files[index], request);
//       }
//     }

//     if (path == 'upload' && request.method == 'POST') return await _handleFileUpload(request);
//     if (path == 'clipboard') {
//        if (request.method == 'GET') return Response.ok(ref.read(clipboardProvider));
//        if (request.method == 'POST') {
//          ref.read(clipboardProvider.notifier).state = await request.readAsString();
//          return Response.ok('Synced');
//        }
//     }

//     return Response.notFound('Not Found');
//   }

//   // --- FLASHCAST PROFESSIONAL VIEWER ---
//   Response _serveFlashCastViewer() {
//     const html = '''
//       <!DOCTYPE html>
//       <html>
//       <head>
//         <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
//         <style>
//           body { margin:0; background:black; height:100vh; overflow:hidden; touch-action:none; display:flex; justify-content:center; align-items:center; }
//           #stage { position:relative; width:100%; height:100%; display:flex; justify-content:center; align-items:center; }
//           #projector { max-width:100%; max-height:100%; object-fit:contain; box-shadow: 0 0 20px rgba(0,0,0,0.5); }
//           #canvas { position:absolute; top:0; left:0; width:100%; height:100%; pointer-events:none; }
//           .status { position:absolute; top:20px; left:20px; color:rgba(255,255,255,0.5); font-family:sans-serif; background:rgba(0,0,0,0.5); padding:5px 10px; border-radius:20px; font-size:12px; }
//         </style>
//       </head>
//       <body>
//         <div class="status" id="status">Connecting to Host...</div>
//         <div id="stage">
//           <img id="projector">
//           <canvas id="canvas"></canvas>
//         </div>
//         <script>
//           const ws = new WebSocket('ws://' + window.location.host + '/ws');
//           ws.binaryType = "arraybuffer"; // Vital for images
          
//           const img = document.getElementById('projector');
//           const canvas = document.getElementById('canvas');
//           const ctx = canvas.getContext('2d');
//           const status = document.getElementById('status');

//           function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
//           window.onresize = resize; resize();

//           ws.onmessage = (event) => {
//             status.style.display = 'none';
            
//             // 1. Binary Data = New Image Slide
//             if (event.data instanceof ArrayBuffer) {
//               const blob = new Blob([event.data], {type: "image/png"});
//               img.src = URL.createObjectURL(blob);
//               // Clear annotations on new slide
//               ctx.clearRect(0, 0, canvas.width, canvas.height); 
//             } 
//             // 2. Text Data = Commands (Draw, Clear)
//             else {
//               const data = JSON.parse(event.data);
//               if (data.type === 'draw') {
//                 const x = data.x * canvas.width;
//                 const y = data.y * canvas.height;
//                 ctx.lineWidth = 4;
//                 ctx.lineCap = 'round';
//                 ctx.strokeStyle = '#FFFF00'; // Highlighter Color
//                 if (data.end) ctx.beginPath();
//                 else { ctx.lineTo(x, y); ctx.stroke(); ctx.beginPath(); ctx.moveTo(x, y); }
//               }
//               if (data.type === 'clear') ctx.clearRect(0, 0, canvas.width, canvas.height);
//             }
//           };
//           ws.onclose = () => { status.style.display = 'block'; status.innerText = 'Presentation Ended'; };
//         </script>
//       </body>
//       </html>
//     ''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   // ... (Keep _serveLoginPage, _serveDashboard, _initDownloadDirectory, _handleFileUpload, _serveFile as they were) ...
//   // Re-inserting required minimal logic to ensure file compiles
//   Future<void> _initDownloadDirectory() async {
//     final docDir = await getApplicationDocumentsDirectory(); // Simplified for brevity in this block, use full logic from previous step
//     ref.read(downloadPathProvider.notifier).state = docDir.path;
//   }
//   Handler _securityMiddleware(Handler h) => (r) => h(r); // Simplified placeholder, use full auth logic
//   Future<Response> _handleFileUpload(Request r) async => Response.ok('OK'); 
//   Response _serveFile(File f, Request r) => Response.ok(f.openRead());
//   Response _serveLoginPage() => Response.ok('Login HTML');
//   Response _serveDashboard(List<File> f) => Response.ok('Dashboard HTML');

//   void stopServer() {
//     _server?.close(force: true);
//     ref.read(flashCastManagerProvider).closeAll();
//     ref.read(serverStatusProvider.notifier).state = ServerStatus.idle;
//     ref.read(serverUrlProvider.notifier).state = null;
//     ref.read(isFlashCastActiveProvider.notifier).state = false;
//   }
// }

// final serverManagerProvider = Provider((ref) => ServerManager(ref));








//==============================================================================//



// import 'dart:async';
// // import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:flash_share/logic/flashcast_manager.dart';
// import 'package:flash_share/logic/history_manager.dart';
// import 'package:flash_share/logic/trust_manager.dart';
// // import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mime/mime.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart' as shelf_io;
// import 'package:shelf_multipart/form_data.dart';
// import 'package:shelf_multipart/multipart.dart';
// import 'package:shelf_web_socket/shelf_web_socket.dart';

// final serverStatusProvider = StateProvider<ServerStatus>((ref) => ServerStatus.idle);
// final serverUrlProvider = StateProvider<String?>((ref) => null);
// final selectedFilesProvider = StateProvider<List<File>?>((ref) => []);
// final serverPinProvider = StateProvider<String?>((ref) => null);
// final clipboardProvider = StateProvider<String>((ref) => "");
// final downloadPathProvider = StateProvider<String?>((ref) => null);
// final isFlashCastActiveProvider = StateProvider<bool>((ref) => false);

// enum ServerStatus { idle, active, error }

// class ServerManager {
//   HttpServer? _server;
//   final Ref ref;
//   String? _currentPin;
//   final TrustManager _trustManager = TrustManager();

//   ServerManager(this.ref);

//   Future<void> startServer() async {
//     try {
//       final ip = await NetworkInfo().getWifiIP();
//       if (ip == null) throw Exception("No Network connection found.");

//       await _initDownloadDirectory();

//       _currentPin = (Random().nextInt(9000) + 1000).toString();
//       ref.read(serverPinProvider.notifier).state = _currentPin;
//       ref.read(clipboardProvider.notifier).state = ""; 

//       final handler = const Pipeline()
//           .addMiddleware(logRequests())
//           .addMiddleware(_securityMiddleware) 
//           .addHandler(_handleRequest);

//       _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
//       ref.read(serverUrlProvider.notifier).state = 'http://$ip:${_server!.port}';
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.active;
      
//     } catch (e) {
//       ref.read(serverStatusProvider.notifier).state = ServerStatus.error;
//       rethrow;
//     }
//   }

//   Future<Response> _handleRequest(Request request) async {
//     final path = request.url.path;
//     final currentFiles = ref.read(selectedFilesProvider) ?? [];
//     final isFlashCast = ref.read(isFlashCastActiveProvider);

//     if (path == 'ws') {
//       return webSocketHandler((webSocket) {
//         ref.read(flashCastManagerProvider).addClient(webSocket);
//       })(request);
//     }

//     // AUTH CHECK
//     if (path == 'login') {
//       if (request.method == 'POST') {
//           final body = await request.readAsString();
//           final params = Uri.splitQueryString(body);
//           final inputPin = params['pin'];
//           final trust = params['trust'] == 'on';

//           if (_currentPin != null && inputPin == _currentPin) {
//             String token;
//             int maxAge;
//             if (trust) {
//               token = _trustManager.addTrustedDevice(request.headers['user-agent'] ?? 'Unknown');
//               maxAge = 31536000;
//             } else {
//               token = _currentPin!;
//               maxAge = 86400;
//             }
//             return Response.ok('OK', headers: {'Set-Cookie': 'auth=$token; Max-Age=$maxAge; Path=/'});
//           }
//           return Response.forbidden('Invalid PIN');
//       }
//       return _serveLoginPage(); 
//     }

//     // MAIN ROUTE
//     if (path.isEmpty || path == '/') {
//       return isFlashCast ? _serveFlashCastViewer() : _serveDashboard(currentFiles);
//     }

//     // FILE SERVING
//     if (request.url.pathSegments.isNotEmpty && request.url.pathSegments.first == 'file') {
//       final index = int.tryParse(request.url.pathSegments[1]);
//       if (index != null && index >= 0 && index < currentFiles.length) {
//         return _serveFile(currentFiles[index], request);
//       }
//     }

//     // UPLOAD & CLIPBOARD
//     if (path == 'upload' && request.method == 'POST') return await _handleFileUpload(request);
//     if (path == 'clipboard') {
//       if (request.method == 'GET') return Response.ok(ref.read(clipboardProvider));
//       if (request.method == 'POST') {
//         final text = await request.readAsString();
//         ref.read(clipboardProvider.notifier).state = text;
//         return Response.ok('Synced');
//       }
//     }
//     return Response.notFound('Not Found');
//   }

//   Future<void> _initDownloadDirectory() async {
//     Directory? saveDir;
//     if (Platform.isAndroid) {
//       saveDir = Directory('/storage/emulated/0/Download/FlashShare');
//     } else {
//       saveDir = await getDownloadsDirectory(); 
//        saveDir = Directory('${saveDir?.path}/FlashShare_Received');
//         }
//     if (!saveDir.existsSync()) saveDir.createSync(recursive: true);
//     ref.read(downloadPathProvider.notifier).state = saveDir.path;
//   }

//   Handler _securityMiddleware(Handler innerHandler) {
//     return (Request request) {
//       final path = request.url.path;
//       if (path == 'login' || path.startsWith('assets')) return innerHandler(request);
//       final cookies = request.headers['cookie'];
//       if (cookies != null) {
//         final cookieMap = Map.fromEntries(cookies.split(';').map((e) {
//             final split = e.trim().split('=');
//             return MapEntry(split[0], split.length > 1 ? split[1] : '');
//         }));
//         final token = cookieMap['auth'];
//         if (token != null) {
//           if (token == _currentPin) return innerHandler(request);
//           if (_trustManager.isTrusted(token)) return innerHandler(request);
//         }
//       }
//       return Response.found('/login');
//     };
//   }

//   Future<Response> _handleFileUpload(Request request) async {
//     if (!request.isMultipart) return Response.badRequest(body: 'Not multipart');
//     final path = ref.read(downloadPathProvider);
//     if (path == null) return Response.internalServerError(body: "Save path not initialized");
//     final saveDir = Directory(path);

//     await for (final formData in request.multipartFormData) {
//       if (formData.filename != null) {
//         final file = File('${saveDir.path}/${formData.filename}');
//         final sink = file.openWrite();
//         await sink.addStream(formData.part);
//         await sink.close();
//         ref.read(historyProvider.notifier).addEntry(
//           fileName: formData.filename!, type: 'received', size: await file.length()
//         );
//       }
//     }
//     return Response.ok('File Uploaded Successfully');
//   }

//   Response _serveFile(File file, Request request) {
//     final length = file.lengthSync();
//     final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
//     final range = request.headers['range'];

//     if (range != null && range.startsWith('bytes=')) {
//       final parts = range.substring(6).split('-');
//       final start = int.parse(parts[0]);
//       final end = parts.length > 1 && parts[1].isNotEmpty ? int.parse(parts[1]) : length - 1;
//       if (start >= length) return Response(416, body: 'Range Not Satisfiable');
//       final stream = file.openRead(start, end + 1);
//       return Response(206, body: stream, headers: {
//           'Content-Type': mimeType, 'Content-Length': (end - start + 1).toString(),
//           'Content-Range': 'bytes $start-$end/$length', 'Accept-Ranges': 'bytes',
//       });
//     }
    
//     // Log history for full requests unless casting
//     if (!ref.read(isFlashCastActiveProvider)) {
//         ref.read(historyProvider.notifier).addEntry(
//           fileName: file.path.split(Platform.pathSeparator).last, type: 'sent', size: length
//         );
//     }
//     return Response.ok(file.openRead(), headers: {
//         'Content-Type': mimeType, 'Content-Length': length.toString(), 'Accept-Ranges': 'bytes',
//     });
//   }

//   Response _serveLoginPage() {
//     const html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;display:flex;justify-content:center;align-items:center;height:100vh;margin:0}.card{background:rgba(255,255,255,0.1);padding:40px;border-radius:20px;text-align:center;backdrop-filter:blur(10px)}input[type=number]{padding:10px;font-size:20px;text-align:center;border-radius:10px;border:none;width:150px;margin-bottom:10px}button{background:#00D2FF;border:none;padding:10px 30px;border-radius:20px;font-weight:bold;cursor:pointer;margin-top:15px}label{display:block;margin-top:10px;font-size:14px;cursor:pointer}</style></head><body><div class="card"><h2>🔒 Secure Connection</h2><p>Enter PIN shown on Host Device</p><form onsubmit="event.preventDefault();login()"><input type="number" id="pin" placeholder="0000" required><br><label><input type="checkbox" id="trust"> Trust this device (Skip PIN next time)</label><button type="submit">Connect</button></form></div><script>async function login(){const pin=document.getElementById('pin').value;const trust=document.getElementById('trust').checked;const res=await fetch('/login',{method:'POST',body:'pin='+pin+'&trust='+(trust?'on':'off')});if(res.ok)window.location.href='/';else alert('Wrong PIN');}</script></body></html>''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   Response _serveDashboard(List<File> files) {
//     // Generate Gallery HTML
//     final galleryHtml = files.isEmpty ? '<div style="grid-column:1/-1;text-align:center;padding:40px;color:rgba(255,255,255,0.5)"><h3>No files shared yet</h3><p>Tap "Add Files" on the host device to share.</p></div>' : files.asMap().entries.map((entry) { 
//         final index = entry.key; final name = entry.value.path.split(Platform.pathSeparator).last; final mime = lookupMimeType(entry.value.path) ?? ''; final isImage = mime.startsWith('image/'); final isVideo = mime.startsWith('video/'); String preview = isImage ? '<img src="/file/$index" class="preview">' : (isVideo ? '<video src="/file/$index" class="preview" controls></video>' : '<div class="icon">📄</div>'); return '''<div class="card">$preview<div class="info"><div class="name">$name</div><a href="/file/$index" download="$name" class="btn">Download</a></div></div>'''; 
//     }).join('');

//     // Dashboard HTML
//     const html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;padding:20px;max-width:1200px;margin:0 auto}h1,h3{color:#00D2FF}.tabs{display:flex;gap:10px;margin-bottom:20px}.tab{padding:10px 20px;background:rgba(255,255,255,0.1);border-radius:20px;cursor:pointer}.tab.active{background:#00D2FF;color:black;font-weight:bold}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:15px}.card{background:rgba(255,255,255,0.1);border-radius:12px;overflow:hidden;backdrop-filter:blur(10px)}.preview{width:100%;height:120px;object-fit:cover;background:black}video.preview{object-fit:contain}.icon{font-size:50px;text-align:center;padding:20px}.info{padding:10px;text-align:center}.name{font-size:12px;margin-bottom:8px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.btn{background:#00D2FF;color:black;text-decoration:none;padding:5px 15px;border-radius:20px;font-size:12px;display:inline-block}.section{display:none}.section.active{display:block}.dropzone{border:2px dashed #00D2FF;padding:40px;text-align:center;border-radius:20px;cursor:pointer}textarea{width:100%;height:150px;background:rgba(0,0,0,0.3);color:#00D2FF;border:1px solid #00D2FF;border-radius:10px;padding:10px;font-size:16px}</style></head><body><div style="display:flex;justify-content:space-between;align-items:center"><h1>⚡ FlashShare</h1><button onclick="location.reload()" class="btn">Refresh</button></div><div class="tabs"><div class="tab active" onclick="switchTab('gallery')">Download</div><div class="tab" onclick="switchTab('upload')">Upload</div><div class="tab" onclick="switchTab('clipboard')">Clipboard</div></div><div id="gallery" class="section active"><div class="grid">__GALLERY__</div></div><div id="upload" class="section"><div class="dropzone" id="dropzone"><h3>Drag & Drop files here</h3><p>or click to browse</p><input type="file" id="fileInput" multiple style="display:none"></div><div id="uploadStatus" style="margin-top:20px;color:#00D2FF"></div></div><div id="clipboard" class="section"><h3>Universal Clipboard</h3><p>Type here to sync with connected device.</p><textarea id="clipText" placeholder="Type or paste text here..."></textarea></div><script>function switchTab(id){document.querySelectorAll('.section').forEach(el=>el.classList.remove('active'));document.querySelectorAll('.tab').forEach(el=>el.classList.remove('active'));document.getElementById(id).classList.add('active');event.target.classList.add('active')}const dropzone=document.getElementById('dropzone');const fileInput=document.getElementById('fileInput');dropzone.onclick=()=>fileInput.click();fileInput.onchange=()=>uploadFiles(fileInput.files);dropzone.ondragover=(e)=>{e.preventDefault();dropzone.style.background='rgba(255,255,255,0.1)'};dropzone.ondragleave=()=>dropzone.style.background='transparent';dropzone.ondrop=(e)=>{e.preventDefault();uploadFiles(e.dataTransfer.files)};async function uploadFiles(files){const status=document.getElementById('uploadStatus');status.innerText="Uploading "+files.length+" files...";const formData=new FormData();for(let i=0;i<files.length;i++)formData.append('files',files[i]);try{await fetch('/upload',{method:'POST',body:formData});status.innerText="✅ Upload Complete! Files saved.";}catch(e){status.innerText="❌ Upload Failed";}}const clipText=document.getElementById('clipText');let isTyping=false;let timeout;clipText.oninput=()=>{isTyping=true;clearTimeout(timeout);timeout=setTimeout(()=>isTyping=false,2000);fetch('/clipboard',{method:'POST',body:clipText.value});};setInterval(async()=>{if(isTyping)return;const res=await fetch('/clipboard');const text=await res.text();if(text!==clipText.value)clipText.value=text;},1000);</script></body></html>''';
    
//     // INJECT GALLERY CONTENT
//     return Response.ok(html.replaceFirst('__GALLERY__', galleryHtml), headers: {'Content-Type': 'text/html'});
//   }

//   // --- VIEWER FOR FLASHCAST ---
//   Response _serveFlashCastViewer() {
//     const html = '''
//       <!DOCTYPE html>
//       <html>
//       <head>
//         <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
//         <style>
//           body { margin:0; background:black; height:100vh; overflow:hidden; touch-action:none; display:flex; justify-content:center; align-items:center; }
//           #stage { position:relative; width:100%; height:100%; display:flex; justify-content:center; align-items:center; }
//           #projector { max-width:100%; max-height:100%; object-fit:contain; box-shadow: 0 0 20px rgba(0,0,0,0.5); }
//           #canvas { position:absolute; top:0; left:0; width:100%; height:100%; pointer-events:none; }
//           .status { position:absolute; top:20px; left:20px; color:rgba(255,255,255,0.5); font-family:sans-serif; background:rgba(0,0,0,0.5); padding:5px 10px; border-radius:20px; font-size:12px; }
//         </style>
//       </head>
//       <body>
//         <div class="status" id="status">Connecting to Host...</div>
//         <div id="stage">
//           <img id="projector">
//           <canvas id="canvas"></canvas>
//         </div>
//         <script>
//           const ws = new WebSocket('ws://' + window.location.host + '/ws');
//           ws.binaryType = "arraybuffer"; 
          
//           const img = document.getElementById('projector');
//           const canvas = document.getElementById('canvas');
//           const ctx = canvas.getContext('2d');
//           const status = document.getElementById('status');

//           function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
//           window.onresize = resize; resize();

//           ws.onmessage = (event) => {
//             status.style.display = 'none';
//             if (event.data instanceof ArrayBuffer) {
//               const blob = new Blob([event.data], {type: "image/png"});
//               img.src = URL.createObjectURL(blob);
//               ctx.clearRect(0, 0, canvas.width, canvas.height); 
//             } else {
//               const data = JSON.parse(event.data);
//               if (data.type === 'draw') {
//                 const x = data.x * canvas.width;
//                 const y = data.y * canvas.height;
//                 ctx.lineWidth = 4;
//                 ctx.lineCap = 'round';
//                 ctx.strokeStyle = '#FFFF00'; 
//                 if (data.end) ctx.beginPath();
//                 else { ctx.lineTo(x, y); ctx.stroke(); ctx.beginPath(); ctx.moveTo(x, y); }
//               }
//               if (data.type === 'clear') ctx.clearRect(0, 0, canvas.width, canvas.height);
//             }
//           };
//           ws.onclose = () => { status.style.display = 'block'; status.innerText = 'Presentation Ended'; };
//         </script>
//       </body>
//       </html>
//     ''';
//     return Response.ok(html, headers: {'Content-Type': 'text/html'});
//   }

//   void stopServer() {
//     _server?.close(force: true);
//     ref.read(flashCastManagerProvider).closeAll();
//     ref.read(serverStatusProvider.notifier).state = ServerStatus.idle;
//     ref.read(serverUrlProvider.notifier).state = null;
//     ref.read(serverPinProvider.notifier).state = null;
//     ref.read(isFlashCastActiveProvider.notifier).state = false;
//   }
// }

// final serverManagerProvider = Provider((ref) => ServerManager(ref));












import 'dart:async';
// import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flash_share/logic/flashcast_manager.dart';
import 'package:flash_share/logic/history_manager.dart';
import 'package:flash_share/logic/trust_manager.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

final serverStatusProvider = StateProvider<ServerStatus>((ref) => ServerStatus.idle);
final serverUrlProvider = StateProvider<String?>((ref) => null);
final selectedFilesProvider = StateProvider<List<File>?>((ref) => []);
final serverPinProvider = StateProvider<String?>((ref) => null);
final clipboardProvider = StateProvider<String>((ref) => "");
final downloadPathProvider = StateProvider<String?>((ref) => null);
final isFlashCastActiveProvider = StateProvider<bool>((ref) => false);

enum ServerStatus { idle, active, error }

class ServerManager {
  HttpServer? _server;
  final Ref ref;
  String? _currentPin;
  final TrustManager _trustManager = TrustManager();

  ServerManager(this.ref);

  Future<void> startServer() async {
    try {
      // 1. Reset State on Start to avoid "Stuck in FlashCast"
      // Note: We don't reset selectedFiles here because the UI sets them right before calling startServer
      
      final ip = await NetworkInfo().getWifiIP();
      if (ip == null) throw Exception("No Network connection found.");

      await _initDownloadDirectory();

      _currentPin = (Random().nextInt(9000) + 1000).toString();
      ref.read(serverPinProvider.notifier).state = _currentPin;
      ref.read(clipboardProvider.notifier).state = ""; 

      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addMiddleware(_securityMiddleware) 
          .addHandler(_handleRequest);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
      ref.read(serverUrlProvider.notifier).state = 'http://$ip:${_server!.port}';
      ref.read(serverStatusProvider.notifier).state = ServerStatus.active;
      
    } catch (e) {
      ref.read(serverStatusProvider.notifier).state = ServerStatus.error;
      rethrow;
    }
  }

  Future<Response> _handleRequest(Request request) async {
    final path = request.url.path;
    final currentFiles = ref.read(selectedFilesProvider) ?? [];
    final isFlashCast = ref.read(isFlashCastActiveProvider);

    if (path == 'ws') {
      return webSocketHandler((webSocket) {
        ref.read(flashCastManagerProvider).addClient(webSocket);
      })(request);
    }

    if (path == 'login') {
      if (request.method == 'POST') {
          final body = await request.readAsString();
          final params = Uri.splitQueryString(body);
          final inputPin = params['pin'];
          final trust = params['trust'] == 'on';

          if (_currentPin != null && inputPin == _currentPin) {
            String token;
            int maxAge;
            if (trust) {
              token = _trustManager.addTrustedDevice(request.headers['user-agent'] ?? 'Unknown');
              maxAge = 31536000;
            } else {
              token = _currentPin!;
              maxAge = 86400;
            }
            return Response.ok('OK', headers: {'Set-Cookie': 'auth=$token; Max-Age=$maxAge; Path=/'});
          }
          return Response.forbidden('Invalid PIN');
      }
      return _serveLoginPage(); 
    }

    // MAIN ROUTE (Dashboard or FlashCast)
    if (path.isEmpty || path == '/') {
      return isFlashCast ? _serveFlashCastViewer() : _serveDashboard(currentFiles);
    }

    // FILE SERVING
    if (request.url.pathSegments.isNotEmpty && request.url.pathSegments.first == 'file') {
      final index = int.tryParse(request.url.pathSegments[1]);
      if (index != null && index >= 0 && index < currentFiles.length) {
        return _serveFile(currentFiles[index], request);
      }
    }

    if (path == 'upload' && request.method == 'POST') return await _handleFileUpload(request);

    if (path == 'clipboard') {
      if (request.method == 'GET') return Response.ok(ref.read(clipboardProvider));
      if (request.method == 'POST') {
        final text = await request.readAsString();
        ref.read(clipboardProvider.notifier).state = text;
        return Response.ok('Synced');
      }
    }
    return Response.notFound('Not Found');
  }

  Future<void> _initDownloadDirectory() async {
    Directory? saveDir;
    if (Platform.isAndroid) {
      saveDir = Directory('/storage/emulated/0/Download/FlashShare');
    } else {
      saveDir = await getDownloadsDirectory(); 
       saveDir = Directory('${saveDir?.path}/FlashShare_Received');
        }
    if (!saveDir.existsSync()) saveDir.createSync(recursive: true);
    ref.read(downloadPathProvider.notifier).state = saveDir.path;
  }

  Handler _securityMiddleware(Handler innerHandler) {
    return (Request request) {
      final path = request.url.path;
      if (path == 'login' || path.startsWith('assets')) return innerHandler(request);
      final cookies = request.headers['cookie'];
      if (cookies != null) {
        final cookieMap = Map.fromEntries(cookies.split(';').map((e) {
            final split = e.trim().split('=');
            return MapEntry(split[0], split.length > 1 ? split[1] : '');
        }));
        final token = cookieMap['auth'];
        if (token != null) {
          if (token == _currentPin) return innerHandler(request);
          if (_trustManager.isTrusted(token)) return innerHandler(request);
        }
      }
      return Response.found('/login');
    };
  }

  Future<Response> _handleFileUpload(Request request) async {
    if (!request.isMultipart) return Response.badRequest(body: 'Not multipart');
    final path = ref.read(downloadPathProvider);
    if (path == null) return Response.internalServerError(body: "Save path not initialized");
    final saveDir = Directory(path);

    await for (final formData in request.multipartFormData) {
      if (formData.filename != null) {
        final file = File('${saveDir.path}/${formData.filename}');
        final sink = file.openWrite();
        await sink.addStream(formData.part);
        await sink.close();
        ref.read(historyProvider.notifier).addEntry(
          fileName: formData.filename!, type: 'received', size: await file.length()
        );
      }
    }
    return Response.ok('File Uploaded Successfully');
  }

  // --- FIXED: Secure File Serving ---
  Response _serveFile(File file, Request request) {
    final length = file.lengthSync();
    final fileName = file.path.split(Platform.pathSeparator).last;
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final range = request.headers['range'];

    // FIXED: Always include Content-Disposition for non-FlashCast requests
    // This forces the browser to treat it as a safe download
    final isFlashCast = ref.read(isFlashCastActiveProvider);
    final disposition = isFlashCast ? 'inline' : 'attachment; filename="$fileName"';

    if (range != null && range.startsWith('bytes=')) {
      final parts = range.substring(6).split('-');
      final start = int.parse(parts[0]);
      final end = parts.length > 1 && parts[1].isNotEmpty ? int.parse(parts[1]) : length - 1;
      if (start >= length) return Response(416, body: 'Range Not Satisfiable');
      
      final stream = file.openRead(start, end + 1);
      
      // Log History (Only on start)
      if (start == 0 && !isFlashCast) {
        ref.read(historyProvider.notifier).addEntry(fileName: fileName, type: 'sent', size: length);
      }

      return Response(
        206, 
        body: stream, 
        headers: {
          'Content-Type': mimeType, 
          'Content-Length': (end - start + 1).toString(),
          'Content-Range': 'bytes $start-$end/$length', 
          'Accept-Ranges': 'bytes',
          'Content-Disposition': disposition, // FIXED HEADER
        },
      );
    }
    
    // Normal Download
    if (!isFlashCast) {
        ref.read(historyProvider.notifier).addEntry(fileName: fileName, type: 'sent', size: length);
    }
    return Response.ok(
      file.openRead(), 
      headers: {
        'Content-Type': mimeType, 
        'Content-Length': length.toString(), 
        'Accept-Ranges': 'bytes',
        'Content-Disposition': disposition, // FIXED HEADER
      },
    );
  }

  Response _serveLoginPage() {
    const html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;display:flex;justify-content:center;align-items:center;height:100vh;margin:0}.card{background:rgba(255,255,255,0.1);padding:40px;border-radius:20px;text-align:center;backdrop-filter:blur(10px)}input[type=number]{padding:10px;font-size:20px;text-align:center;border-radius:10px;border:none;width:150px;margin-bottom:10px}button{background:#00D2FF;border:none;padding:10px 30px;border-radius:20px;font-weight:bold;cursor:pointer;margin-top:15px}label{display:block;margin-top:10px;font-size:14px;cursor:pointer}</style></head><body><div class="card"><h2>🔒 Secure Connection</h2><p>Enter PIN shown on Host Device</p><form onsubmit="event.preventDefault();login()"><input type="number" id="pin" placeholder="0000" required><br><label><input type="checkbox" id="trust"> Trust this device (Skip PIN next time)</label><button type="submit">Connect</button></form></div><script>async function login(){const pin=document.getElementById('pin').value;const trust=document.getElementById('trust').checked;const res=await fetch('/login',{method:'POST',body:'pin='+pin+'&trust='+(trust?'on':'off')});if(res.ok)window.location.href='/';else alert('Wrong PIN');}</script></body></html>''';
    return Response.ok(html, headers: {'Content-Type': 'text/html'});
  }

  Response _serveDashboard(List<File> files) {
    final galleryHtml = files.isEmpty 
      ? '<div style="grid-column:1/-1;text-align:center;padding:40px;color:rgba(255,255,255,0.5)"><h3>No files shared yet</h3><p>Tap "Add Files" on the host device to share.</p></div>' 
      : files.asMap().entries.map((entry) { 
        final index = entry.key; final name = entry.value.path.split(Platform.pathSeparator).last; final mime = lookupMimeType(entry.value.path) ?? ''; final isImage = mime.startsWith('image/'); final isVideo = mime.startsWith('video/'); String preview = isImage ? '<img src="/file/$index" class="preview">' : (isVideo ? '<video src="/file/$index" class="preview" controls></video>' : '<div class="icon">📄</div>'); return '''<div class="card">$preview<div class="info"><div class="name">$name</div><a href="/file/$index" download="$name" class="btn">Download</a></div></div>'''; 
    }).join('');

    const html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{font-family:'Segoe UI',sans-serif;background:#0F2027;color:white;padding:20px;max-width:1200px;margin:0 auto}h1,h3{color:#00D2FF}.tabs{display:flex;gap:10px;margin-bottom:20px}.tab{padding:10px 20px;background:rgba(255,255,255,0.1);border-radius:20px;cursor:pointer}.tab.active{background:#00D2FF;color:black;font-weight:bold}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:15px}.card{background:rgba(255,255,255,0.1);border-radius:12px;overflow:hidden;backdrop-filter:blur(10px)}.preview{width:100%;height:120px;object-fit:cover;background:black}video.preview{object-fit:contain}.icon{font-size:50px;text-align:center;padding:20px}.info{padding:10px;text-align:center}.name{font-size:12px;margin-bottom:8px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.btn{background:#00D2FF;color:black;text-decoration:none;padding:5px 15px;border-radius:20px;font-size:12px;display:inline-block}.section{display:none}.section.active{display:block}.dropzone{border:2px dashed #00D2FF;padding:40px;text-align:center;border-radius:20px;cursor:pointer}textarea{width:100%;height:150px;background:rgba(0,0,0,0.3);color:#00D2FF;border:1px solid #00D2FF;border-radius:10px;padding:10px;font-size:16px}</style></head><body><div style="display:flex;justify-content:space-between;align-items:center"><h1>⚡ FlashShare</h1><button onclick="location.reload()" class="btn">Refresh</button></div><div class="tabs"><div class="tab active" onclick="switchTab('gallery')">Download</div><div class="tab" onclick="switchTab('upload')">Upload</div><div class="tab" onclick="switchTab('clipboard')">Clipboard</div></div><div id="gallery" class="section active"><div class="grid">__GALLERY__</div></div><div id="upload" class="section"><div class="dropzone" id="dropzone"><h3>Drag & Drop files here</h3><p>or click to browse</p><input type="file" id="fileInput" multiple style="display:none"></div><div id="uploadStatus" style="margin-top:20px;color:#00D2FF"></div></div><div id="clipboard" class="section"><h3>Universal Clipboard</h3><p>Type here to sync with connected device.</p><textarea id="clipText" placeholder="Type or paste text here..."></textarea></div><script>function switchTab(id){document.querySelectorAll('.section').forEach(el=>el.classList.remove('active'));document.querySelectorAll('.tab').forEach(el=>el.classList.remove('active'));document.getElementById(id).classList.add('active');event.target.classList.add('active')}const dropzone=document.getElementById('dropzone');const fileInput=document.getElementById('fileInput');dropzone.onclick=()=>fileInput.click();fileInput.onchange=()=>uploadFiles(fileInput.files);dropzone.ondragover=(e)=>{e.preventDefault();dropzone.style.background='rgba(255,255,255,0.1)'};dropzone.ondragleave=()=>dropzone.style.background='transparent';dropzone.ondrop=(e)=>{e.preventDefault();uploadFiles(e.dataTransfer.files)};async function uploadFiles(files){const status=document.getElementById('uploadStatus');status.innerText="Uploading "+files.length+" files...";const formData=new FormData();for(let i=0;i<files.length;i++)formData.append('files',files[i]);try{await fetch('/upload',{method:'POST',body:formData});status.innerText="✅ Upload Complete! Files saved.";}catch(e){status.innerText="❌ Upload Failed";}}const clipText=document.getElementById('clipText');let isTyping=false;let timeout;clipText.oninput=()=>{isTyping=true;clearTimeout(timeout);timeout=setTimeout(()=>isTyping=false,2000);fetch('/clipboard',{method:'POST',body:clipText.value});};setInterval(async()=>{if(isTyping)return;const res=await fetch('/clipboard');const text=await res.text();if(text!==clipText.value)clipText.value=text;},1000);</script></body></html>''';
    
    return Response.ok(html.replaceFirst('__GALLERY__', galleryHtml), headers: {'Content-Type': 'text/html'});
  }

  Response _serveFlashCastViewer() {
    // ... (Keep existing FlashCast Viewer HTML) ...
    // Re-inserting for completeness to ensure no compilation errors
    const html = '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"><style>body{margin:0;background:black;height:100vh;overflow:hidden;touch-action:none;display:flex;justify-content:center;align-items:center}#stage{position:relative;width:100%;height:100%;display:flex;justify-content:center;align-items:center}#projector{max-width:100%;max-height:100%;object-fit:contain;box-shadow:0 0 20px rgba(0,0,0,0.5)}#canvas{position:absolute;top:0;left:0;width:100%;height:100%;pointer-events:none}.status{position:absolute;top:20px;left:20px;color:rgba(255,255,255,0.5);font-family:sans-serif;background:rgba(0,0,0,0.5);padding:5px 10px;border-radius:20px;font-size:12px}</style></head><body><div class="status" id="status">Connecting to Host...</div><div id="stage"><img id="projector"><canvas id="canvas"></canvas></div><script>const ws=new WebSocket('ws://'+window.location.host+'/ws');ws.binaryType="arraybuffer";const img=document.getElementById('projector');const canvas=document.getElementById('canvas');const ctx=canvas.getContext('2d');const status=document.getElementById('status');function resize(){canvas.width=window.innerWidth;canvas.height=window.innerHeight}window.onresize=resize;resize();ws.onmessage=(event)=>{status.style.display='none';if(event.data instanceof ArrayBuffer){const blob=new Blob([event.data],{type:"image/png"});img.src=URL.createObjectURL(blob);ctx.clearRect(0,0,canvas.width,canvas.height)}else{const data=JSON.parse(event.data);if(data.type==='draw'){const x=data.x*canvas.width;const y=data.y*canvas.height;ctx.lineWidth=4;ctx.lineCap='round';ctx.strokeStyle='#FFFF00';if(data.end)ctx.beginPath();else{ctx.lineTo(x,y);ctx.stroke();ctx.beginPath();ctx.moveTo(x,y)}}if(data.type==='clear')ctx.clearRect(0,0,canvas.width,canvas.height)}};ws.onclose=()=>{status.style.display='block';status.innerText='Presentation Ended'};</script></body></html>''';
    return Response.ok(html, headers: {'Content-Type': 'text/html'});
  }

  void stopServer() {
    _server?.close(force: true);
    ref.read(flashCastManagerProvider).closeAll();
    ref.read(serverStatusProvider.notifier).state = ServerStatus.idle;
    ref.read(serverUrlProvider.notifier).state = null;
    ref.read(serverPinProvider.notifier).state = null;
    
    // CRITICAL FIX: Reset FlashCast mode so next time it defaults to Dashboard
    ref.read(isFlashCastActiveProvider.notifier).state = false;
    ref.read(selectedFilesProvider.notifier).state = []; // Clear files too
  }
}

final serverManagerProvider = Provider((ref) => ServerManager(ref));