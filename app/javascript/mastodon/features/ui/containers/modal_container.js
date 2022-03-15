import { connect } from 'react-redux';
import { openModal, closeModal } from '../../../actions/modal';
import ModalRoot from '../components/modal_root';

const mapStateToProps = state => ({
<<<<<<< HEAD
  type: state.getIn(['modal', 0, 'modalType'], null),
  props: state.getIn(['modal', 0, 'modalProps'], {}),
=======
  ignoreFocus: state.getIn(['modal', 'ignoreFocus']),
  type: state.getIn(['modal', 'stack', 0, 'modalType'], null),
  props: state.getIn(['modal', 'stack', 0, 'modalProps'], {}),
>>>>>>> v3.5.0rc1
});

const mapDispatchToProps = dispatch => ({
  onClose (confirmationMessage, ignoreFocus = false) {
    if (confirmationMessage) {
      dispatch(
        openModal('CONFIRM', {
          message: confirmationMessage.message,
          confirm: confirmationMessage.confirm,
          onConfirm: () => dispatch(closeModal(undefined, { ignoreFocus })),
        }),
      );
    } else {
      dispatch(closeModal(undefined, { ignoreFocus }));
    }
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(ModalRoot);
