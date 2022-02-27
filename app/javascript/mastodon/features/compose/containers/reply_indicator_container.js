import { connect } from 'react-redux';
import { cancelReplyCompose, cancelQuoteCompose } from '../../../actions/compose';
import { makeGetStatus } from '../../../selectors';
import ReplyIndicator from '../components/reply_indicator';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, props) => {
    let statusId = state.getIn(['compose', 'id'], null);
    let editing  = true;

    if (statusId === null) {
      statusId = state.getIn(['compose', props.quote ? 'quote_from' : 'in_reply_to']);
      editing  = false;
    }

    return {
      status: getStatus(state, { id: statusId }),
      quote: props.quote,
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
