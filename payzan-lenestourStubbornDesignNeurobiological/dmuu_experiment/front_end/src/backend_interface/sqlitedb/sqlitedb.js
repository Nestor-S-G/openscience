import axios from "axios";
import { BACKEND_API_DOWNLOADDB, BACKEND_API_UPLOADDB } from "../backend_url";

const downloadDb_filename = "experiments.db";

export function uploadDb(file, hook) {
    const formData = new FormData();

    formData.append("file", file);
    axios
        .post(BACKEND_API_UPLOADDB, formData)
        .then(() => {
            console.log("Successfully uploaded sqlite3 db");
            if (hook) hook();
        })
        .catch(() => console.log("Failed to upload sqlite3 db"));
}

export function downloadDb() {
    axios
        .get(BACKEND_API_DOWNLOADDB, {
            responseType: "arraybuffer",
        })
        .then((request) => {
            const url = window.URL.createObjectURL(
                new Blob([request.data], {
                    type: "application/vnd.sqlite3",
                })
            );
            const link = document.createElement("a");
            link.href = url;
            link.setAttribute("download", downloadDb_filename);
            document.body.appendChild(link);
            link.click();
            URL.revokeObjectURL(url);
        })
        .catch((err) => console.log(err));
}
