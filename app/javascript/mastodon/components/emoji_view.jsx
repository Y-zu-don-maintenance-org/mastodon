import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { injectIntl } from 'react-intl';
import emojify from '../features/emoji/emoji';
import classNames from 'classnames';

export default class EmojiView extends React.PureComponent {

  static propTypes = {
    name: PropTypes.string,
    url: PropTypes.string,
    staticUrl: PropTypes.string,
  };

  render () {
    const { name, url, staticUrl } = this.props;

    let emojiHtml = null;
    if (url) {
      let customEmojis = {};
      customEmojis[`:${name}:`] = { url, static_url: staticUrl };
      emojiHtml = emojify(`:${name}:`, customEmojis);
    } else {
      emojiHtml = emojify(name);
    }

    return (
      <span className='emoji' dangerouslySetInnerHTML={{ __html: emojiHtml }} />
    );
  }

}
