import React, {useState, useRef} from 'react';
import {
  StyleSheet,
  Button,
  View,
  Modal,
  Platform,
  TextInput,
  Text,
  ScrollView,
  Linking,
  Alert,
} from 'react-native';
import {SafeAreaView, SafeAreaProvider} from 'react-native-safe-area-context';
import {WebView} from 'react-native-webview';
import type {WebViewMessageEvent} from 'react-native-webview';
import {Picker} from '@react-native-picker/picker';

// 預設值
const DEFAULT_VALUES = {
  baseUrl: 'https://uat-chat-client.omnichat.ai',
  appkey:
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0ZWFtTmFtZSI6IjFkNWYxMDk1LTVkZDEtNDFmYS1hOThkLWI1NzkwYmYyNzViNSJ9.r7T6ro7U7UkD9Mjbtfh_usklv-0vbJqog-zyjmXZIVM',
  ssokey: 'Qazpkw2jhbtejovJwfyoTyx12rhapq',
  clientId: 'QA_TEST',
  memberId: 'QA_TEST',
  name: 'QA_TEST',
  email: 'qa_test@example.com',
  phone: '+886912345678',
};

// 注入的 JavaScript 代碼，用於設置 message handler
// 同時支援 iOS 和 Android
const INJECTED_JAVASCRIPT = `
  (function() {
    // 統一的訊息發送函數
    function sendMessageToRN(message) {
      if (window.ReactNativeWebView) {
        window.ReactNativeWebView.postMessage(JSON.stringify(message));
      }
    }

    // 為 iOS 模擬 WKScriptMessageHandler
    // iOS 使用: window.webkit.messageHandlers.omnichatLiveChatHandler.postMessage({action: "...", ...})
    window.webkit = window.webkit || {};
    window.webkit.messageHandlers = window.webkit.messageHandlers || {};
    window.webkit.messageHandlers.omnichatLiveChatHandler = {
      postMessage: function(message) {
        sendMessageToRN(message);
      }
    };

    // 為 Android 模擬 JavaScriptInterface
    // Android 使用: window.omnichatLiveChatHandler.linkClicked(link)
    //           或: window.omnichatLiveChatHandler.closeLiveChat()
    window.omnichatLiveChatHandler = {
      linkClicked: function(link) {
        sendMessageToRN({
          action: 'link_clicked',
          link: link
        });
      },
      closeLiveChat: function() {
        sendMessageToRN({
          action: 'close-live-chat'
        });
      }
    };

    console.log('Omnichat message handler initialized for both iOS and Android');
  })();
  true; // 必須返回 true
`;

function App(): React.JSX.Element {
  // 管理 Modal 是否可見
  const [modalVisible, setModalVisible] = useState(false);
  const webViewRef = useRef<WebView>(null);

  // 管理各個輸入欄位的值
  const [baseUrl, setBaseUrl] = useState(DEFAULT_VALUES.baseUrl);
  const [appkey, setAppkey] = useState(DEFAULT_VALUES.appkey);
  const [ssokey, setSsokey] = useState(DEFAULT_VALUES.ssokey);
  const [clientId, setClientId] = useState(DEFAULT_VALUES.clientId);
  const [memberId, setMemberId] = useState(DEFAULT_VALUES.memberId);
  const [name, setName] = useState(DEFAULT_VALUES.name);
  const [email, setEmail] = useState(DEFAULT_VALUES.email);
  const [phone, setPhone] = useState(DEFAULT_VALUES.phone);

  // 處理來自 WebView 的訊息
  const handleWebViewMessage = (event: WebViewMessageEvent) => {
    try {
      const data = JSON.parse(event.nativeEvent.data);
      console.log('Received message from WebView:', data);

      const action = data.action;

      if (action === 'link_clicked') {
        // 處理開啟外部連結
        const link = data.link;
        if (link) {
          Alert.alert(
            '開啟外部連結',
            `是否要在外部瀏覽器開啟此連結？\n${link}`,
            [
              {text: '取消', style: 'cancel'},
              {
                text: '開啟',
                onPress: () => {
                  Linking.openURL(link).catch(err =>
                    console.error('無法開啟連結:', err),
                  );
                },
              },
            ],
          );
        }
      } else if (action === 'close-live-chat') {
        // 關閉聊天室
        setModalVisible(false);
      }
    } catch (error) {
      console.error('Error parsing WebView message:', error);
    }
  };

  // 動態組合 URL
  const deviceType = Platform.OS;
  let webViewUrl = `${baseUrl}/?embedded=1&appkey=${appkey}&ssokey=${ssokey}&clientId=${clientId}&device=${deviceType}`;

  // 添加可選參數
  if (memberId) webViewUrl += `&memberId=${encodeURIComponent(memberId)}`;
  if (name) webViewUrl += `&name=${encodeURIComponent(name)}`;
  if (email) webViewUrl += `&email=${encodeURIComponent(email)}`;
  if (phone) webViewUrl += `&phone=${encodeURIComponent(phone)}`;

  return (
    <SafeAreaProvider>
      <SafeAreaView style={styles.container}>
        <ScrollView style={styles.scrollView}>
          <View style={styles.formContainer}>
            <Text style={styles.title}>WebView 參數設定</Text>

            {/* Base URL 輸入 */}
            <Text style={styles.label}>Base URL:</Text>
            <View style={styles.pickerContainer}>
              <Picker
                style={styles.picker}
                itemStyle={styles.pickerItem}
                selectedValue={baseUrl}
                onValueChange={(value: string) => setBaseUrl(value)}>
                <Picker.Item
                  label="新版本（預設）"
                  value="https://uat-chat-client.omnichat.ai"
                />
                <Picker.Item
                  label="舊版本"
                  value="https://uat-chat-plugin.easychat.co"
                />
              </Picker>
            </View>

            {/* App Key 輸入 */}
            <Text style={styles.label}>App Key:</Text>
            <TextInput
              style={styles.input}
              value={appkey}
              onChangeText={setAppkey}
              placeholder="輸入 App Key"
              autoCapitalize="none"
              multiline
            />

            {/* SSO Key 輸入 */}
            <Text style={styles.label}>SSO Key:</Text>
            <TextInput
              style={styles.input}
              value={ssokey}
              onChangeText={setSsokey}
              placeholder="輸入 SSO Key"
              autoCapitalize="none"
            />

            {/* Client ID 輸入 */}
            <Text style={styles.label}>Client ID:</Text>
            <TextInput
              style={styles.input}
              value={clientId}
              onChangeText={setClientId}
              placeholder="輸入 Client ID"
              autoCapitalize="none"
            />

            {/* Member ID 輸入 */}
            <Text style={styles.label}>Member ID:</Text>
            <TextInput
              style={styles.input}
              value={memberId}
              onChangeText={setMemberId}
              placeholder="輸入 Member ID (optional)"
              autoCapitalize="none"
            />

            {/* Name 輸入 */}
            <Text style={styles.label}>Name (optional):</Text>
            <TextInput
              style={styles.input}
              value={name}
              onChangeText={setName}
              placeholder="輸入用戶名稱 (optional)"
              autoCapitalize="words"
            />

            {/* Email 輸入 */}
            <Text style={styles.label}>Email (optional):</Text>
            <TextInput
              style={styles.input}
              value={email}
              onChangeText={setEmail}
              placeholder="輸入 Email (optional)"
              autoCapitalize="none"
              keyboardType="email-address"
            />

            {/* Phone 輸入 */}
            <Text style={styles.label}>Phone (optional):</Text>
            <TextInput
              style={styles.input}
              value={phone}
              onChangeText={setPhone}
              placeholder="輸入電話 (optional)"
              autoCapitalize="none"
              keyboardType="phone-pad"
            />

            {/* 預覽完整 URL */}
            <Text style={styles.label}>完整 URL:</Text>
            <Text style={styles.urlPreview}>{webViewUrl}</Text>

            {/* 開啟 WebView 按鈕 */}
            <View style={styles.buttonContainer}>
              <Button
                title="開啟 WebView"
                onPress={() => setModalVisible(true)}
              />
            </View>
          </View>
        </ScrollView>

        {/* WebView Modal */}
        <Modal
          animationType="slide"
          visible={modalVisible}
          onRequestClose={() => {
            setModalVisible(false);
          }}>
          <SafeAreaView style={styles.modalContainer}>
            {/* 關閉按鈕 */}
            <View style={styles.closeButtonContainer}>
              <Button title="關閉" onPress={() => setModalVisible(false)} />
            </View>

            {/* WebView */}
            <WebView
              ref={webViewRef}
              style={styles.webView}
              source={{uri: webViewUrl}}
              javaScriptEnabled={true}
              domStorageEnabled={true}
              injectedJavaScript={INJECTED_JAVASCRIPT}
              onMessage={handleWebViewMessage}
              onError={syntheticEvent => {
                const {nativeEvent} = syntheticEvent;
                console.error('WebView error: ', nativeEvent);
              }}
            />
          </SafeAreaView>
        </Modal>
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

// 樣式表
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollView: {
    flex: 1,
  },
  formContainer: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
    color: '#333',
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    marginTop: 15,
    marginBottom: 5,
    color: '#555',
  },
  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 14,
    color: '#333',
  },
  pickerContainer: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    height: 200,
    justifyContent: 'center',
  },
  picker: {
    width: '100%',
  },
  pickerItem: {
    height: 120,
    fontSize: 18,
    color: '#333',
  },
  urlPreview: {
    backgroundColor: '#e8f5e9',
    borderWidth: 1,
    borderColor: '#c8e6c9',
    borderRadius: 8,
    padding: 12,
    fontSize: 12,
    color: '#2e7d32',
    marginTop: 5,
  },
  buttonContainer: {
    marginTop: 25,
    marginBottom: 20,
  },
  modalContainer: {
    flex: 1,
  },
  closeButtonContainer: {
    alignItems: 'flex-end',
    paddingHorizontal: 10,
    paddingTop: 10,
    backgroundColor: '#fff',
  },
  webView: {
    flex: 1,
  },
});

export default App;