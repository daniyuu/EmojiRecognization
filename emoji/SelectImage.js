/**
 * Created by Daniyuu on 6/20/17.
 */
import React from "react";
import {CameraRoll, Image, ListView, PixelRatio, StyleSheet, Text, TouchableOpacity, View} from "react-native";
import Datastore from "react-native-local-mongodb";

export default class SelectImage extends React.Component {
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

    constructor() {
        super();
        const ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 != r2});
        this.state = {
            avatarSource: null,
            dataSource: ds.cloneWithRows(['row1', 'row2'])
        };
    }

    selectPhotoTapped() {
        CameraRoll.getPhotos({
            first: 2,
            groupTypes: 'Album',
            groupName: 'Emoji'
        })
            .then(r => console.info(r));

        db = new Datastore({filename: 'testCyy', autoload: true});
        // db.insert({id: '123'}, function (err, newDoc) {
        //
        // });

        db.find({}, function (err, docs) {
            console.info(docs);
        });

    };

    render() {
        return (
            <View>
                <TouchableOpacity onPress={this.selectPhotoTapped.bind(this)}>
                    <View style={[styles.avatar, styles.avatarContainer, {marginBottom: 20}]}>
                        {
                            this.state.avatarSource === null ? <Text>Select a photo</Text> :
                                <Image style={styles.avatar} source={this.state.avatarSource}/>
                        }
                    </View>
                </TouchableOpacity>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF'
    },
    avatarContainer: {
        borderColor: '#9B9B9B',
        borderWidth: 1 / PixelRatio.get(),
        justifyContent: 'center',
        alignItems: 'center'
    },
    avatar: {
        borderRadius: 75,
        width: 150,
        height: 150
    }
});