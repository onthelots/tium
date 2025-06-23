import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();

  String url = ''; // 현재 url
  String title = ''; // title
  double progress = 0;
  bool? isSecure; // secure 여부
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    url = widget.url;
  }

  @override
  void dispose() {
    print('자원해제 진행');
    InAppWebViewController.clearAllCache();
    webViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        /// leading : pop Button
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        /// Title
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FutureBuilder<bool>(
              future: webViewController?.canGoBack() ?? Future.value(false),
              builder: (context, snapshot) {
                final canGoBack = snapshot.hasData ? snapshot.data! : false;
                return IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: !canGoBack
                      ? null
                      : () {
                    webViewController?.goBack();
                  },
                );
              },
            ),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isSecure != null
                            ? Icon(isSecure == true ? Icons.lock : Icons.lock_open,
                            color: isSecure == true ? Colors.green : Colors.red,
                            size: 12)
                            : Container(),

                        const SizedBox(
                          width: 5,
                        ),

                        Flexible(
                            child: Text(
                              url,
                              style: textTheme.bodyMedium,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            )),
                      ],
                    )
                  ],
                )),

            FutureBuilder<bool>(
              future: webViewController?.canGoForward() ?? Future.value(false),
              builder: (context, snapshot) {
                final canGoForward = snapshot.hasData ? snapshot.data! : false;
                return IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: !canGoForward
                      ? null
                      : () {
                    webViewController?.goForward();
                  },
                );
              },
            )
          ],
        ),
      ),

      /// 중앙 WebView, progress Bar
      body: Column(children: <Widget>[
        Expanded(
            child: Stack(
              children: [
                // WebView
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                  initialSettings: InAppWebViewSettings(
                      transparentBackground: true,
                      safeBrowsingEnabled: true,
                      isFraudulentWebsiteWarningEnabled: true),
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                    if (!kIsWeb &&
                        defaultTargetPlatform == TargetPlatform.android) {
                      await controller.startSafeBrowsing();
                    }
                  },
                  onLoadStart: (controller, url) {
                    if (url != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          this.url = url.toString();
                          isSecure = urlIsSecure(url);
                        });
                      });
                    }
                  },
                  onLoadStop: (controller, url) async {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        this.url = url.toString();
                      });
                    });

                    final sslCertificate = await controller.getCertificate();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        isSecure = sslCertificate != null || (url != null && urlIsSecure(url));
                      });
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    });
                  },
                  onTitleChanged: (controller, title) {
                    if (title != null) {
                      setState(() {
                        this.title = title;
                      });
                    }
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    final url = navigationAction.request.url;
                    if (navigationAction.isForMainFrame &&
                        url != null &&
                        ![
                          'http',
                          'https',
                          'file',
                          'chrome',
                          'data',
                          'javascript',
                          'about'
                        ].contains(url.scheme)) {
                      if (await canLaunchUrl(url)) {
                        launchUrl(url);
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            )),
      ]),

      /// 하단 앱바
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // 공유
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share(url, subject: title);
              },
            ),

            // 새로고침
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                webViewController?.reload();
              },
            ),

            // 뒤로라기
            PopupMenuButton<int>(
              onSelected: (item) => handleClick(item),
              color: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // 둥근 모서리
              ),
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  enabled: false,
                  child: Text(
                    'options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.open_in_browser, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        '다른 앱에서 열기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.auto_delete_outlined, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        '검색 데이터 삭제하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void handleClick(int item) async {
    switch (item) {
      case 0:
        await InAppBrowser.openWithSystemBrowser(url: WebUri(url));
        break;
      case 1:
        await InAppWebViewController.clearAllCache();
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          await webViewController?.clearHistory();
        }
        setState(() {});
        break;
    }
  }

  static bool urlIsSecure(Uri url) {
    return (url.scheme == "https") || isLocalizedContent(url);
  }

  static bool isLocalizedContent(Uri url) {
    return (url.scheme == "file" ||
        url.scheme == "chrome" ||
        url.scheme == "data" ||
        url.scheme == "javascript" ||
        url.scheme == "about");
  }
}