import React from "react";
import {CameraRoll, StyleSheet, Text, View} from "react-native";

import AppInfo from "./AppInfo";
import SelectImage from "./SelectImage";

var imgURL = "http://www.hrewqrewqangge.com/blog/images/logo.png";

export default class App extends React.Component {
    getImgDescription() {
        var imgPath = "http://wx4.sinaimg.cn/large/62528dc5gy1ff15pgorhgj20rs0rsn1e.jpg";
        fetch("https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/ocr?language=zh-Hans", {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Ocp-Apim-Subscription-Key': AppInfo.SubscriptionKey
            },
            body: JSON.stringify({'url': imgPath})
        })
            .then((response) => response.json())
            .then((responseData) => {
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
                <Text onPress={this.getImgDescription.bind(this)}>GetImgDescription</Text>
                <SelectImage/>
                <SearchBar/>
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
