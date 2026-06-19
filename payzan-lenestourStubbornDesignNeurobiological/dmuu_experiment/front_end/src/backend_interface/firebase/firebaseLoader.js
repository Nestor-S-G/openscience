import firebase from 'firebase/app';
import 'firebase/database';
import firebaseConfig from './firebaseConfig';

const PENDING = 'PENDING';
const FAILED = 'FAILED';
const SUCCESS = 'SUCCESS';
const MAX_RETRIES = 3;
const RETRY_INTERVAL_MS = 1000;

class FirebaseLoader {
    constructor()
    {
        this.firebase = firebase.initializeApp(firebaseConfig);
        this.db = this.firebase.database();
        this.retries = 0;
        this.status = PENDING;
        this.config = null;
    }

    checkRetries(connected)
    {
        if (this.retries < MAX_RETRIES)
        {
            if (connected)
            {
                this.status = SUCCESS;
            }
            this.retries += 1;
        }
        else
        {
            this.status = FAILED;
        }
    }

    checkFirebaseConnection()
    {
        const dbref = this.db.ref('.info/connected');

        dbref.once('value', (snap) => {
            this.checkRetries(snap.val());
        })
    }

    checkConnection()
    {
        return new Promise((resolve, reject) => {
            const check = setInterval(() => {
                console.log("Connecting...");
                this.checkFirebaseConnection()
                if (this.status === SUCCESS)
                {
                    resolve();
                }
                else if (this.status === FAILED)
                {
                    reject();
                    this.db.goOffline();
                }
                if (this.status !== PENDING)
                {
                    console.log("Clearing interval");
                    clearInterval(check);
                }
            }, RETRY_INTERVAL_MS);
        });
    }

    async getConfig()
    {
        await this.checkConnection();
        if (this.status === SUCCESS)
        {
            const snapshot = await this.db.ref('config').once('value');
            this.config = snapshot.val();
            this.db.goOffline();
            console.log("Connection success!");
            return this.config;
        }
        else
        {
            throw new Error("Failed to load config from firebase");
        }
    }

    updateConfig(config)
    {
        this.db.goOnline();
        this.db.ref('config').set(config)
            .then(res => {
                console.log("Firebase updated");
                this.db.goOffline();
            })
            .catch(err => {
                console.log(err);
            });
    }
}

export default FirebaseLoader;