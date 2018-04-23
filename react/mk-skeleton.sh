#!/bin/bash

name="$1"

if [[ -z "$name" ]]; then
  echo 'please provide a name of the new component'
  exit 1
fi

if [[ -d "$name" ]]; then
  echo "dir \"$name\" already exists"
  exit 1
fi

#
# content
#

declare -A contents

contents[actions]="import { types } from './constants';

export const actions = {

};"


contents[api]="import { localRequest } from '../utils/';

import { urls } from './constants';

const api = {

};

export default api;"

contents[constants]="import { ONESURGERY_HOST } from '../constants';

//
// ACTION TYPES
//

export const types = {

};

//
// URL
//

export const urls = {

};"

contents[index]="export { actions } from './actions';
export { selectors } from './selectors';"

contents[reducer]="import update from 'immutability-helper';

import { types } from './constants';

const initialState = {

};

export function ${name}Reducer(state = initialState, { payload, type }) {
  switch (type) {

    default: {
      return state;
    }
  }
}"

contents[sagas]="import { delay } from 'redux-saga';
import { call, fork, put, takeLatest } from 'redux-saga/effects';
import { toastr } from 'react-redux-toastr';
import { setError } from '../utils';
import api from './api';
import { types } from './constants';

export function* watch${name^}() {
  yield takeLatest(, );
}

export const ${name}Sagas = [
  fork(watch${name^})
];"

contents[selectors]="import { createSelector } from 'reselect';

export const selectors = {

};"

#
# -----------
#

mkdir "$name"

for key in "${!contents[@]}"; do
  echo "${contents[$key]}" > "$name/$key.js"
done

echo 'Created: '
ls -1 "$name"
