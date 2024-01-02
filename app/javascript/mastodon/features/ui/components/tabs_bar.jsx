import PropTypes from 'prop-types';
import { Component } from 'react';
import { defineMessages, injectIntl } from 'react-intl';
import ColumnLink from './column_link';
import NotificationsCounterIcon from './notifications_counter_icon';

import { ReactComponent as HomeIcon } from '@material-symbols/svg-600/outlined/home-fill.svg';
import { ReactComponent as MoreHorizIcon } from '@material-symbols/svg-600/outlined/more_horiz.svg';
import { ReactComponent as PublicIcon } from '@material-symbols/svg-600/outlined/public.svg';
import { ReactComponent as SearchIcon } from '@material-symbols/svg-600/outlined/search.svg';

const messages = defineMessages({
  home: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  explore: { id: 'explore.title', defaultMessage: 'Explore' },
  firehose: { id: 'column.firehose', defaultMessage: 'Live feeds' },
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Private mentions' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  bookmarks: { id: 'navigation_bar.bookmarks', defaultMessage: 'Bookmarks' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  followsAndFollowers: { id: 'navigation_bar.follows_and_followers', defaultMessage: 'Follows and followers' },
  about: { id: 'navigation_bar.about', defaultMessage: 'About' },
  search: { id: 'navigation_bar.search', defaultMessage: 'Search' },
  gettingStarted: { id: 'getting_started.heading', defaultMessage: 'Getting Started' },
});

class TabsBar extends Component {

  static contextTypes = {
    router: PropTypes.object.isRequired,
    identity: PropTypes.object.isRequired,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
  };

  isFirehoseActive = (match, location) => {
    return match || location.pathname.startsWith('/public');
  };

  render () {
    const { intl } = this.props;

    return (
      <div className='tabs-bar__wrapper'>
        <ColumnLink transparent to='/home' icon='home' iconComponent={HomeIcon} text={intl.formatMessage(messages.home)} />
        <ColumnLink transparent to='/notifications' icon={<NotificationsCounterIcon className='column-link__icon' />} text={intl.formatMessage(messages.notifications)} />
        <ColumnLink transparent to='/public/local'  iconComponent={PublicIcon} isActive={this.isFirehoseActive} icon='globe' text={intl.formatMessage(messages.firehose)} />
        <ColumnLink transparent to='/search' icon='search' iconComponent={SearchIcon} text={intl.formatMessage(messages.search)} />
        <ColumnLink transparent to='/getting-started' icon='bars' iconComponent={MoreHorizIcon} text={intl.formatMessage(messages.gettingStarted)} />
      </div>
    );
  }

}

export default injectIntl(TabsBar);
