mport type { CustomUserManager } from "~/models/task.model";


export const getCustomUserManager = ()=>{
    return useFetch<Page<CustomUserManager>>("http://localhost:8001/api/task/");
}