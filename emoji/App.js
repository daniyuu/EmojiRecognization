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
