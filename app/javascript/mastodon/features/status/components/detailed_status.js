import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import { mapStateToProps, quote } from '../../../components/status';
import StatusContent from '../../../components/status_content';
import MediaGallery from '../../../components/media_gallery';
import { Link } from 'react-router-dom';
import { injectIntl, defineMessages, FormattedDate } from 'react-intl';
import Card from './card';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Video from '../../video';
import Audio from '../../audio';
import scheduleIdleTask from '../../ui/util/schedule_idle_task';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import AnimatedNumber from 'mastodon/components/animated_number';
import PictureInPicturePlaceholder from 'mastodon/components/picture_in_picture_placeholder';
import EditedTimestamp from 'mastodon/components/edited_timestamp';

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted_short: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers-only' },
  direct_short: { id: 'privacy.direct.short', defaultMessage: 'Direct' },
});

export default @connect(mapStateToProps) @injectIntl
class DetailedStatus extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map,
    onOpenMedia: PropTypes.func.isRequired,
    onOpenVideo: PropTypes.func.isRequired,
    onToggleHidden: PropTypes.func.isRequired,
    onQuoteToggleHidden: PropTypes.func.isRequired,
    measureHeight: PropTypes.bool,
    onHeightChange: PropTypes.func,
    domain: PropTypes.string.isRequired,
    compact: PropTypes.bool,
    quoteMuted: PropTypes.bool,
    showMedia: PropTypes.bool,
    showQuoteMedia: PropTypes.bool,
    pictureInPicture: ImmutablePropTypes.contains({
      inUse: PropTypes.bool,
      available: PropTypes.bool,
    }),
    onToggleMediaVisibility: PropTypes.func,
    onQuoteToggleMediaVisibility: PropTypes.func,
  };

  state = {
    height: null,
  };

  handleAccountClick = (e) => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey) && this.context.router) {
      const acct = e.currentTarget.getAttribute('data-acct');
      e.preventDefault();
      this.context.router.history.push(`/@${acct}`);
    }

    e.stopPropagation();
  }

  handleOpenVideo = (options) => {
    this.props.onOpenVideo(this.props.status.getIn(['media_attachments', 0]), options);
  }

  handleExpandedToggle = () => {
    this.props.onToggleHidden(this.props.status);
  }

  handleExpandedQuoteToggle = () => {
    this.props.onQuoteToggleHidden(this.props.status);
  }

  handleQuoteClick = () => {
    if (!this.context.router) {
      return;
    }

    const { status } = this.props;
    this.context.router.history.push(`/statuses/${status.getIn(['quote', 'id'])}`);
  }

  _measureHeight (heightJustChanged) {
    if (this.props.measureHeight && this.node) {
      scheduleIdleTask(() => this.node && this.setState({ height: Math.ceil(this.node.scrollHeight) + 1 }));

      if (this.props.onHeightChange && heightJustChanged) {
        this.props.onHeightChange();
      }
    }
  }

  setRef = c => {
    this.node = c;
    this._measureHeight();
  }

  componentDidUpdate (prevProps, prevState) {
    this._measureHeight(prevState.height !== this.state.height);
  }

  handleModalLink = e => {
    e.preventDefault();

    let href;

    if (e.target.nodeName !== 'A') {
      href = e.target.parentNode.href;
    } else {
      href = e.target.href;
    }

    window.open(href, 'mastodon-intent', 'width=445,height=600,resizable=no,menubar=no,status=no,scrollbars=yes');
  }

  render () {
    const status = (this.props.status && this.props.status.get('reblog')) ? this.props.status.get('reblog') : this.props.status;
    const outerStyle = { boxSizing: 'border-box' };
    const { intl, compact, pictureInPicture, quoteMuted } = this.props;

    if (!status) {
      return null;
    }

    let applicationLink = '';
    let reblogLink = '';
    let reblogIcon = 'retweet';
    let favouriteLink = '';
    let edited = '';

    if (this.props.measureHeight) {
      outerStyle.height = `${this.state.height}px`;
    }

    const identity = (status, _0, _1, quote = false) => (
      <a href={status.getIn(['account', 'url'])} onClick={this.handleAccountClick} data-acct={status.getIn(['account', 'acct'])} className='detailed-status__display-name'>
        <div className='detailed-status__display-avatar'><Avatar account={status.get('account')} size={quote ? 18 : 48} /></div>
        <DisplayName account={status.get('account')} localDomain={this.props.domain} />
      </a>
    );

    const media = (status, quote = false) => {
      if (pictureInPicture.get('inUse')) {
        return <PictureInPicturePlaceholder />;
      } else if (status.get('media_attachments').size > 0) {
        if (status.getIn(['media_attachments', 0, 'type']) === 'audio') {
          const attachment = status.getIn(['media_attachments', 0]);

          return (
            <Audio
              src={attachment.get('url')}
              alt={attachment.get('description')}
              duration={attachment.getIn(['meta', 'original', 'duration'], 0)}
              poster={attachment.get('preview_url') || status.getIn(['account', 'avatar_static'])}
              backgroundColor={attachment.getIn(['meta', 'colors', 'background'])}
              foregroundColor={attachment.getIn(['meta', 'colors', 'foreground'])}
              accentColor={attachment.getIn(['meta', 'colors', 'accent'])}
              height={150}
              quote={quote}
            />
          );
        } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
          const attachment = status.getIn(['media_attachments', 0]);

          return (
            <Video
              preview={attachment.get('preview_url')}
              frameRate={attachment.getIn(['meta', 'original', 'frame_rate'])}
              blurhash={attachment.get('blurhash')}
              src={attachment.get('url')}
              alt={attachment.get('description')}
              width={300}
              height={150}
              inline
              onOpenVideo={this.handleOpenVideo}
              sensitive={status.get('sensitive')}
              visible={this.props.showMedia}
              onToggleVisibility={this.props.onToggleMediaVisibility}
              quote={quote}
            />
          );
        } else {
          return (
            <MediaGallery
              standalone
              sensitive={status.get('sensitive')}
              media={status.get('media_attachments')}
              height={300}
              onOpenMedia={this.props.onOpenMedia}
              visible={this.props.showMedia}
              onToggleVisibility={this.props.onToggleMediaVisibility}
              quote={quote}
            />
          );
        }
      } else if (status.get('spoiler_text').length === 0) {
        return (
          <Card
            sensitive={status.get('sensitive')}
            onOpenMedia={this.props.onOpenMedia}
            card={status.get('card', null)}
            quote={quote}
          />
        );
      }

      return null;
    };

    if (status.get('application')) {
      applicationLink = <React.Fragment> · <a className='detailed-status__application' href={status.getIn(['application', 'website'])} target='_blank' rel='noopener noreferrer'>{status.getIn(['application', 'name'])}</a></React.Fragment>;
    }

    const visibilityIconInfo = {
      'public': { icon: 'globe', text: intl.formatMessage(messages.public_short) },
      'unlisted': { icon: 'unlock', text: intl.formatMessage(messages.unlisted_short) },
      'private': { icon: 'lock', text: intl.formatMessage(messages.private_short) },
      'direct': { icon: 'envelope', text: intl.formatMessage(messages.direct_short) },
    };

    const visibilityIcon = visibilityIconInfo[status.get('visibility')];
    const visibilityLink = <React.Fragment> · <Icon id={visibilityIcon.icon} title={visibilityIcon.text} /></React.Fragment>;

    if (['private', 'direct'].includes(status.get('visibility'))) {
      reblogLink = '';
    } else if (this.context.router) {
      reblogLink = (
        <React.Fragment>
          <React.Fragment> · </React.Fragment>
          <Link to={`/@${status.getIn(['account', 'acct'])}/${status.get('id')}/reblogs`} className='detailed-status__link'>
            <Icon id={reblogIcon} />
            <span className='detailed-status__reblogs'>
              <AnimatedNumber value={status.get('reblogs_count')} />
            </span>
          </Link>
        </React.Fragment>
      );
    } else {
      reblogLink = (
        <React.Fragment>
          <React.Fragment> · </React.Fragment>
          <a href={`/interact/${status.get('id')}?type=reblog`} className='detailed-status__link' onClick={this.handleModalLink}>
            <Icon id={reblogIcon} />
            <span className='detailed-status__reblogs'>
              <AnimatedNumber value={status.get('reblogs_count')} />
            </span>
          </a>
        </React.Fragment>
      );
    }

    if (this.context.router) {
      favouriteLink = (
        <Link to={`/@${status.getIn(['account', 'acct'])}/${status.get('id')}/favourites`} className='detailed-status__link'>
          <Icon id='star' />
          <span className='detailed-status__favorites'>
            <AnimatedNumber value={status.get('favourites_count')} />
          </span>
        </Link>
      );
    } else {
      favouriteLink = (
        <a href={`/interact/${status.get('id')}?type=favourite`} className='detailed-status__link' onClick={this.handleModalLink}>
          <Icon id='star' />
          <span className='detailed-status__favorites'>
            <AnimatedNumber value={status.get('favourites_count')} />
          </span>
        </a>
      );
    }

    if (status.get('edited_at')) {
      edited = (
        <React.Fragment>
          <React.Fragment> · </React.Fragment>
          <EditedTimestamp statusId={status.get('id')} timestamp={status.get('edited_at')} />
        </React.Fragment>
      );
    }

    return (
      <div style={outerStyle}>
        <div ref={this.setRef} className={classNames('detailed-status', `detailed-status-${status.get('visibility')}`, { compact })}>
          {identity(status, null, null, false)}

          <StatusContent status={status} expanded={!status.get('hidden')} onExpandedToggle={this.handleExpandedToggle} />

          {media(status, false)}

          {quote(status, false, quoteMuted, this.handleQuoteClick, this.handleExpandedQuoteToggle, identity, media, this.context.router)}

          <div className='detailed-status__meta'>
            <a className='detailed-status__datetime' href={status.get('url')} target='_blank' rel='noopener noreferrer'>
              <FormattedDate value={new Date(status.get('created_at'))} hour12={false} year='numeric' month='short' day='2-digit' hour='2-digit' minute='2-digit' />
            </a>{edited}{visibilityLink}{applicationLink}{reblogLink} · {favouriteLink}
          </div>
        </div>
      </div>
    );
  }

}
