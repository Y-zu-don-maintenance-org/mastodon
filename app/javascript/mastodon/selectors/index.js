import { List as ImmutableList, Map as ImmutableMap } from 'immutable';
import { createSelector } from 'reselect';

import { toServerSideType } from 'mastodon/utils/filters';

import { me } from '../initial_state';

export { makeGetAccount } from "./accounts";

const getFilters = (state, { contextType }) => {
  if (!contextType) return null;

  const serverSideType = toServerSideType(contextType);
  const now = new Date();

  return state.get('filters').filter((filter) => filter.get('context').includes(serverSideType) && (filter.get('expires_at') === null || filter.get('expires_at') > now));
};

export const makeGetStatus = () => {
  return createSelector(
    [
      (state, { id }) => state.getIn(['statuses', id]),
      (state, { id }) => state.getIn(['statuses', state.getIn(['statuses', id, 'reblog'])]),
      (state, { id }) => state.getIn(['statuses', state.getIn(['statuses', id, 'quote_id'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', id, 'account'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', state.getIn(['statuses', id, 'reblog']), 'account'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', state.getIn(['statuses', id, 'quote_id']), 'account'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', state.getIn(['statuses', id, 'reblog']), 'quote', 'account'])]),
      (state, { id }) => state.getIn(['relationships', state.getIn(['statuses', id, 'account'])]),
      (state, { id }) => state.getIn(['relationships', state.getIn(['statuses', state.getIn(['statuses', id, 'reblog']), 'account'])]),
      (state, { id }) => state.getIn(['relationships', state.getIn(['statuses', state.getIn(['statuses', id, 'quote_id']), 'account'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['accounts', state.getIn(['statuses', id, 'account']), 'moved'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['accounts', state.getIn(['statuses', state.getIn(['statuses', id, 'reblog']), 'account']), 'moved'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['accounts', state.getIn(['statuses', state.getIn(['statuses', id, 'quote_id']), 'account']), 'moved'])]),
      getFilters,
    ],

    (statusBase, statusReblog, statusQuote, accountBase, accountReblog, accountQuote, accountReblogQuote, relationshipBase, relationshipReblog, relationshipQuote, movedBase, movedReblog, movedQuote, filters) => {
      if (!statusBase || statusBase.get('isLoading')) {
        return null;
      }

      accountBase = accountBase.withMutations(map => {
        map.set('relationship', relationshipBase);
        map.set('moved', movedBase);
      });

      if (statusReblog) {
        accountReblog = accountReblog.withMutations(map => {
          map.set('relationship', relationshipReblog);
          map.set('moved', movedReblog);
        });
        statusReblog = statusReblog.set('account', accountReblog);
      } else {
        statusReblog = null;
      }

      if (statusQuote) {
        accountQuote = accountQuote.withMutations(map => {
          map.set('relationship', relationshipQuote);
          map.set('moved', movedQuote);
        });
        statusQuote = statusQuote.set('account', accountQuote);
      } else {
        statusQuote = null;
      }

      if (statusReblog && accountReblogQuote) {
        statusReblog = statusReblog.setIn(['quote', 'account'], accountReblogQuote);
      }

      let filtered = false;
      if ((accountReblog || accountBase).get('id') !== me && filters) {
        let filterResults = statusReblog?.get('filtered') || statusBase.get('filtered') || ImmutableList();
        if (filterResults.some((result) => filters.getIn([result.get('filter'), 'filter_action']) === 'hide')) {
          return null;
        }
        filterResults = filterResults.filter(result => filters.has(result.get('filter')));
        if (!filterResults.isEmpty()) {
          filtered = filterResults.map(result => filters.getIn([result.get('filter'), 'title']));
        }
      }

      return statusBase.withMutations(map => {
        map.set('reblog', statusReblog);
        map.set('quote', statusQuote);
        map.set('account', accountBase);
        map.set('matched_filters', filtered);
      });
    },
  );
};

export const makeGetPictureInPicture = () => {
  return createSelector([
    (state, { id }) => state.get('picture_in_picture').statusId === id,
    (state) => state.getIn(['meta', 'layout']) !== 'mobile',
  ], (inUse, available) => ImmutableMap({
    inUse: inUse && available,
    available,
  }));
};

const ALERT_DEFAULTS = {
  dismissAfter: 5000,
  style: false,
};

export const getAlerts = createSelector(state => state.get('alerts'), alerts =>
  alerts.map(item => ({
    ...ALERT_DEFAULTS,
    ...item,
  })).toArray());

export const makeGetNotification = () => createSelector([
  (_, base)             => base,
  (state, _, accountId) => state.getIn(['accounts', accountId]),
], (base, account) => base.set('account', account));

export const makeGetReport = () => createSelector([
  (_, base) => base,
  (state, _, targetAccountId) => state.getIn(['accounts', targetAccountId]),
], (base, targetAccount) => base.set('target_account', targetAccount));

export const getAccountGallery = createSelector([
  (state, id) => state.getIn(['timelines', `account:${id}:media`, 'items'], ImmutableList()),
  state       => state.get('statuses'),
  (state, id) => state.getIn(['accounts', id]),
], (statusIds, statuses, account) => {
  let medias = ImmutableList();

  statusIds.forEach(statusId => {
    const status = statuses.get(statusId).set('account', account);
    medias = medias.concat(status.get('media_attachments').map(media => media.set('status', status)));
  });

  return medias;
});

export const getAccountHidden = createSelector([
  (state, id) => state.getIn(['accounts', id, 'hidden']),
  (state, id) => state.getIn(['relationships', id, 'following']) || state.getIn(['relationships', id, 'requested']),
  (state, id) => id === me,
], (hidden, followingOrRequested, isSelf) => {
  return hidden && !(isSelf || followingOrRequested);
});

export const getStatusList = createSelector([
  (state, type) => state.getIn(['status_lists', type, 'items']),
], (items) => items.toList());
