// src/app/interceptors/token.interceptor.ts
import { HttpInterceptorFn } from '@angular/common/http';

export const TokenInterceptor: HttpInterceptorFn = (req, next) => {
  //const token = localStorage.getItem('token'); // récupère le token

  //if (token) {
    //const cloned = req.clone({
      //headers: req.headers.set('Authorization', 'Bearer ' + token)
    //});

    //console.log('✅ Token ajouté à la requête :', token);
    //return next(cloned);
  //}

  console.warn('⚠️ Aucun token trouvé !');
  return next(req);
};
