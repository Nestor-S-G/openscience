/**
 * In charge of loading the config and storing into the store
 * will not render anything
 */

import store from "../../redux/store";
import FirebaseLoader from "../firebase/firebaseLoader";
import {
    configFetchRequest,
    configFetchSuccess,
} from "../../redux/config/configActions";
import default_config from "./default_config.json";
import axios from "axios";
import { BACKEND_API_CONFIG, BACKEND_URL } from "../backend_url";

const FIREBASE = "firebase";
export const FLASK_BACKEND = "flask_backend";

const CONFIG_SOURCE = FLASK_BACKEND;

class ConfigLoader {
    constructor() {
        if (CONFIG_SOURCE === FIREBASE) {
            console.log("Creating firebaseloader");
            this.firebaseLoader = new FirebaseLoader();
        }
        this.loaded = false;
    }

    loadConfig() {
        if (!this.isStoreConfigLoaded()) {
            if (CONFIG_SOURCE === FIREBASE)
                this.loadFromFireBase();
            else if (CONFIG_SOURCE === FLASK_BACKEND)
                this.loadFromFlaskBackend();
        }
    }

    isStoreConfigLoaded = () => {
        return store.getState().config.loaded;
    };

    loadConfigLocally = () => {
        console.log("Failed to connect to remote server, loading local config");
        store.dispatch(
            configFetchSuccess({
                config: default_config.config,
                source: "local",
            })
        );
    };

    loadFromFlaskBackend = () => {
        store.dispatch(configFetchRequest());
        axios
            .get(BACKEND_API_CONFIG)
            .then((res) => {
                store.dispatch(
                    configFetchSuccess({
                        config: res.data.config,
                        source: FLASK_BACKEND,
                    })
                );
                this.loaded = true;
                console.log(`Config loaded from: ${BACKEND_URL}`);
            })
            .catch(() => {
                this.loadConfigLocally();
            });
    };

    loadFromFireBase = () => {
        store.dispatch(configFetchRequest());
        this.firebaseLoader
            .getConfig()
            .then((config) => {
                store.dispatch(
                    configFetchSuccess({ config, source: "firebase" })
                );
                this.loaded = true;
            })
            .catch(() => {
                this.loadConfigLocally();
            });
    };

    // Returns true if config successfully updated, false otherwise
    updateConfig = (config_params) => {
        let success = false;
        if (store.getState().config.source === "firebase") {
            const config = {
                params: config_params,
                block_config: store.getState().config.config.block_config,
            };
            this.firebaseLoader.updateConfig(config);
            store.dispatch(configFetchSuccess({ config, source: "firebase" }));
            success = true;
        } else if (store.getState().config.source === FLASK_BACKEND) {
            const config = {
                config: {
                    params: config_params,
                    block_config: store.getState().config.config.block_config,
                },
            };
            axios
                .post(BACKEND_API_CONFIG, config)
                .then(() => {
                    console.log(`Updated config on: ${BACKEND_URL}`);
                })
                .catch(() => {
                    console.log(`Failed to update configon: ${BACKEND_URL}`);
                });
            store.dispatch(
                configFetchSuccess({
                    config: config.config,
                    source: FLASK_BACKEND,
                })
            );
            success = true;
        } else {
            console.log("Config not sent to firebase");
        }

        return success;
    };
}

export default ConfigLoader;
