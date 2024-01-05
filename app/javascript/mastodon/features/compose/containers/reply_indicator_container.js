import { connect } from 'react-redux';

import { cancelReplyCompose, cancelQuoteCompose } from '../../../actions/compose';
import { makeGetStatus } from '../../../selectors';
import ReplyIndicator from '../components/reply_indicator';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state) => {
    let statusId = state.getIn(['compose', 'id'], null);
    let editing  = true;
    let quote    = false;

    if (statusId === null) {
      statusId = state.getIn(['compose', 'quote_from']);
      editing  = false;
      quote    = true;
    }

    if (statusId === null) {
      statusId = state.getIn(['compose', 'in_reply_to']);
      quote    = false;
    }

    return {
      status: getStatus(state, { id: statusId }),
      quote,
      editing,
    };
  };

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({

  onCancel (quote) {
    dispatch(quote ? cancelQuoteCompose() : cancelReplyCompose());
  },

});

export default connect(makeMapStateToProps, mapDispatchToProps)(ReplyIndicator);
