/**
 * Created by Daniyuu on 6/20/17.
 */
import React from "react";
import {CameraRoll, Image, PixelRatio, StyleSheet, Text, TouchableOpacity, View} from "react-native";
import Datastore from "react-native-local-mongodb";

export default class SelectImage extends React.Component {
    state = {
        avatarSource: null,
        videoSource: null
    };s

    selectPhotoTapped() {
        const options = {
            quality: 1.0,
            maxWidth: 500,
            maxHeight: 500,
            storageOptions: {
                skipBackup: true
            }
        };

        CameraRoll.getPhotos({
            first: 2,
            assetType: 'All'
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
            <View style={styles.container}>
                <TouchableOpacity onPress={this.selectPhotoTapped.bind(this)}>
                    <View style={[styles.avatar, styles.avatarContainer, {marginBottom: 20}]}>
                        {
                            this.state.avatarSource === null ? <Text>Select a photo</Text> :
                                <Image style={styles.avatar} source={this.state.avatarSource}/>
                        }
                    </View>
                </TouchableOpacity>

                <TouchableOpacity>
                    <View style={[styles.avatar, styles.avatarContainer]}>
                        <Text>Select a video</Text>
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