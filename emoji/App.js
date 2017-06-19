import React from 'react';
import {
    StyleSheet,
    Text,
    View,
    CameraRoll,
    Image
} from 'react-native';

var imgURL = "http://www.hrewqrewqangge.com/blog/images/logo.png";

export default class App extends React.Component {
    getImgDescription(){
        var SubscriptionKey = 'd1aa9018f9584282a979a2ae5dc89b0c';
        var imgPath = "http://wx4.sinaimg.cn/large/62528dc5gy1ff15pgorhgj20rs0rsn1e.jpg";
        fetch("https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/ocr?language=zh-Hans", {
            method: 'POST',
            headers:{
                'Content-Type': 'application/json',
                'Ocp-Apim-Subscription-Key': SubscriptionKey
            },
            body: JSON.stringify({'url': imgPath})
        })
            .then((response)=>response.json())
            .then((responseData)=>{
            alert(JSON.stringify(responseData))
            })

    }

    saveImg(img) {
        var promise = CameraRoll.saveToCameraRoll(img);
        promise.then(function (result) {
            alert("success");

        }).catch(function (error) {
            alert("fail");
        })
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>Hello</Text>
                <Image style={styles.img}
                       source={{uri:imgURL}}
                       resizeMode="contain"/>
                <View>
                    <Text onPress={this.saveImg.bind(this, imgURL)} style={[styles.saveImg]}></Text>
                </View>
                <Text onPress={this.getImgDescription.bind(this)}>GetImgDescription</Text>
            </View>

        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
        alignItems: 'center',
        justifyContent: 'center',
    },
    img: {
        height: 98,
        width: 300

    },
    saveImg: {
        height: 30,
        padding: 6,
        textAlign: 'center',
        backgroundColor: '#3bc1ff',
        color: '#fff',
        marginTop: 10
    }
});
